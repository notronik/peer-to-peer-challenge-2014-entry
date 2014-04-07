part of game;

class PlayerPhysicsComponent extends EntityComponent {

    double playerWalkSpeed = 15.0;
    double playerForceSpeed = 900.0;
    double playerJumpSpeed = 35.0;

    // Player dimensions
    double playerWidth = 0.5;
    double playerFriction = 1.0;
    double playerRestitution = 0.3;
    double playerMass = 2.0;
    bool lastOnGround = false;

    bool walking = false;
    double ticksJumpThrottled = 0.0;

    JsObject ray_groundDetection_direction = new JsObject(context["THREE"]["Vector3"], [0, -1, 0]);
    List<JsObject> ray_insertIntersect_directions = [
        new JsObject(context["THREE"]["Vector3"], [-0.266405, -0.506732, -0.819909]),
        new JsObject(context["THREE"]["Vector3"], [-0.862104, -0.506732, -0.000000]),
        new JsObject(context["THREE"]["Vector3"], [-0.266405, -0.506732, 0.819909]),
        new JsObject(context["THREE"]["Vector3"], [0.697457, -0.506732, 0.506732]),
        new JsObject(context["THREE"]["Vector3"], [0.697457, -0.506732, -0.506732]),
        new JsObject(context["THREE"]["Vector3"], [-0.309017, 0.000000, -0.951057]),
        new JsObject(context["THREE"]["Vector3"], [-1.000000, 0.000000, -0.000000]),
        new JsObject(context["THREE"]["Vector3"], [-0.309017, 0.000000, 0.951057]),
        new JsObject(context["THREE"]["Vector3"], [0.809017, 0.000000, 0.587785]),
        new JsObject(context["THREE"]["Vector3"], [0.809017, 0.000000, -0.587785]),
        new JsObject(context["THREE"]["Vector3"], [-0.266405, 0.506732, -0.819909]),
        new JsObject(context["THREE"]["Vector3"], [-0.862104, 0.506732, -0.000000]),
        new JsObject(context["THREE"]["Vector3"], [-0.266405, 0.506732, 0.819909]),
        new JsObject(context["THREE"]["Vector3"], [0.697457, 0.506732, 0.506732]),
        new JsObject(context["THREE"]["Vector3"], [0.697457, 0.506732, -0.506732]),
        new JsObject(context["THREE"]["Vector3"], [-0.115167, -0.927957, -0.354448]),
        new JsObject(context["THREE"]["Vector3"], [-0.372689, -0.927957, 0.000000]),
        new JsObject(context["THREE"]["Vector3"], [-0.115167, -0.927957, 0.354448]),
        new JsObject(context["THREE"]["Vector3"], [0.301511, -0.927957, 0.219061]),
        new JsObject(context["THREE"]["Vector3"], [0.301511, -0.927957, -0.219061]),
        new JsObject(context["THREE"]["Vector3"], [-0.115167, 0.927957, -0.354448]),
        new JsObject(context["THREE"]["Vector3"], [-0.372689, 0.927957, 0.000000]),
        new JsObject(context["THREE"]["Vector3"], [-0.115167, 0.927957, 0.354448]),
        new JsObject(context["THREE"]["Vector3"], [0.301511, 0.927957, 0.219061]),
        new JsObject(context["THREE"]["Vector3"], [0.301511, 0.927957, -0.219061]),
    ];
    double smallestDistanceThreshold = 0.7;
    JsObject ray_groundDetection, ray_insertIntersect;

    PlayerPhysicsComponent(){
        ray_groundDetection = new JsObject(context["THREE"]["Raycaster"], [
           new JsObject(context["THREE"]["Vector3"], [0, 0, 0]),
           ray_groundDetection_direction,
           0.0,
           10.0
       ]);
       ray_insertIntersect = new JsObject(context["THREE"]["Raycaster"], [
            new JsObject(context["THREE"]["Vector3"], [0, 0, 0]),
            ray_groundDetection_direction,
            0.0,
            2.0
       ]);
    }

    void init(){
        JsObject geometry = new JsObject(context["THREE"]["SphereGeometry"], [playerWidth, 60, 60]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [
            new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject.jsify({
                "color" : 0xffffff,
                "ambient" : 0xffffff,
                "map": context["THREE"]["ImageUtils"].callMethod("loadTexture", ["res/player.png"])
            })]),
            playerFriction,
            playerRestitution
        ]);
        entity.sceneAttachment = new JsObject(context["Physijs"]["SphereMesh"], [geometry, material, playerMass]);
        entity.sceneAttachment["geometry"].callMethod("computeBoundingBox");

        nf[EntityNotifications.NF_PLAYER_PHYSICS_TICK] = physTick;
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){
        walk(delta);
    }

    int lastTime = new DateTime.now().millisecondsSinceEpoch;
    void physTick(int event, dynamic payload){
        int now = new DateTime.now().millisecondsSinceEpoch;
        double difference = (now.toDouble() - lastTime.toDouble()) / 1000.0;
        lastTime = now;;

        notify(EntityNotifications.NF_PLAYER_CAMERA_UPDATE, difference);
        doesIntersectWithInsert();
        // Limit speed of walking
        JsObject linvel = entity.sceneAttachment.callMethod("getLinearVelocity");
        Vector3 linearVelocity = new Vector3(linvel["x"].toDouble(), linvel["y"].toDouble(), linvel["z"].toDouble());

        double linearSpeed = linearVelocity.xz.length;
        if(linearSpeed > playerWalkSpeed){
            linearVelocity.x *= playerWalkSpeed / linearSpeed;
            linearVelocity.z *= playerWalkSpeed / linearSpeed;
            entity.sceneAttachment.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linearVelocity.x, linearVelocity.y, linearVelocity.z])]);
        }
    }

    void walk(num delta){
        Map<String, dynamic> keybindings = getify(EntityNotifications.GF_KEYBINDINGS);
        Vector3 rotation = getify(EntityNotifications.GF_CAMERA_ROTATION);
        assert(keybindings != null && rotation != null);
        Vector3 change = new Vector3.all(0.0);
        if(keybindings["walk_forwards"]["down"] == true){
            change.x += Math.cos(radians(rotation.y - 90.0));
            change.z += Math.sin(radians(rotation.y - 90.0));
        }
        if(keybindings["walk_backwards"]["down"] == true){
            change.x += Math.cos(radians(rotation.y + 90.0));
            change.z += Math.sin(radians(rotation.y + 90.0));
        }
        if(keybindings["walk_right"]["down"] == true){
            change.x += Math.cos(radians(rotation.y));
            change.z += Math.sin(radians(rotation.y));
        }
        if(keybindings["walk_left"]["down"] == true){
            change.x += Math.cos(radians(rotation.y + 180.0));
            change.z += Math.sin(radians(rotation.y + 180.0));
        }
        change = change.normalize();
        if(ticksJumpThrottled > 0.0){
            ticksJumpThrottled--;
        }
        if(keybindings["walk_jump"]["down"] == true && onGround == true && ticksJumpThrottled == 0.0){
            change.y += playerJumpSpeed;
            JsObject linvel = entity.sceneAttachment.callMethod("getLinearVelocity");
            entity.sceneAttachment.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linvel["x"].toDouble(), 0.0, linvel["z"].toDouble()])]);
            ticksJumpThrottled = 6.0;

            entity.sceneAttachment.callMethod("applyCentralImpulse", [new JsObject(context["THREE"]["Vector3"], [0.0, change.y * delta * playerJumpSpeed, 0.0])]);
            change.y = 0.0;
        }
        if(keybindings["fly_up"]["down"] == true){
            change.y += 6;
        }
        if(keybindings["fly_down"]["down"] == true){
            change.y -= 6;
        }
        walking = !(change.x == 0.0 && change.z == 0.0);

        entity.sceneAttachment.callMethod("applyCentralForce", [new JsObject(context["THREE"]["Vector3"], [change.x * delta * playerForceSpeed, change.y * delta * playerForceSpeed, change.z * delta * playerForceSpeed])]);
    }

    bool get onGround {
        JsObject raycaster = new JsObject(context["THREE"]["Raycaster"], [
            entity.sceneAttachment["position"],
            new JsObject(context["THREE"]["Vector3"], [0, -1, 0]),
            0.0,
            10.0
        ]);
        JsArray objects = new JsArray.from(entity.game.world.getEntityMeshes(getEntitiesBelowPlayer()));
        JsArray result = raycaster.callMethod("intersectObjects", [objects, false]);
        if(result.length > 0){
            double distance = MathUtils.roundTo(result.elementAt(0)["distance"] - playerWidth, 100.0);
            bool wonGround = distance <= 0.25;
            lastOnGround = wonGround;
            return wonGround;
        }else{
            lastOnGround = false;
            return false;
        }
    }

    void doesIntersectWithInsert(){
        double smallestDistance = 100.0;
        JsObject smallestDistanceObject;
        List<CSEntity> objs = entity.game.world.getEntitiesOfType(EntityType.E_PIPE_INSERT);
        JsArray entities = new JsArray.from(entity.game.world.getEntityMeshes(objs));
        for(JsObject direction in ray_insertIntersect_directions){
            ray_insertIntersect.callMethod("set", [
                entity.sceneAttachment["position"],
                direction
            ]);
            JsArray result = ray_insertIntersect.callMethod("intersectObjects", [entities, false]);
            if(result.length > 0){
                double distance = MathUtils.roundTo(result.elementAt(0)["distance"], 100.0);
                if(distance < smallestDistance){
                    smallestDistance = distance;
                    smallestDistanceObject = result.elementAt(0)["object"];
                }
            }
        }
        if(smallestDistanceObject != null){
            if(smallestDistance < smallestDistanceThreshold){
                CSEntity theInsert = entity.game.world.getEntityByMesh(smallestDistanceObject, objs);
                if(theInsert != null){
                    theInsert.notify(EntityNotifications.NF_PLAYER_INTERACT_COLLIDE, [this, smallestDistance, smallestDistanceObject]);
                }
            }
        }
    }

    List<CSEntity> getEntitiesBelowPlayer(){
        List<CSEntity> entitiesBelowPlayer = new List<CSEntity>();
        double playerPos = MathUtils.roundTo(entity.sceneAttachment["position"]["y"].toDouble() - this.playerWidth, 100.0);
        for(CSEntity e in entity.game.world.attachedEntities){
            if(e != null){
                try{
                    if(MathUtils.roundTo(e.sceneAttachment["geometry"]["boundingBox"]["min"]["y"].toDouble(), 100.0) <= playerPos){
                        entitiesBelowPlayer.add(e);
                    }
                }catch(ex){}
            }
        }
        return entitiesBelowPlayer;
    }

    void jump(){
        if(ticksJumpThrottled == 0.0){
            JsObject linvel = entity.sceneAttachment.callMethod("getLinearVelocity");
            entity.sceneAttachment.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linvel["x"].toDouble(), 0.0, linvel["z"].toDouble()])]);
            ticksJumpThrottled = 6.0;

            entity.sceneAttachment.callMethod("applyCentralImpulse", [new JsObject(context["THREE"]["Vector3"], [0.0, playerJumpSpeed * (1.0/120.0) * playerJumpSpeed, 0.0])]);
        }
    }

}