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

    PlayerPhysicsComponent(){

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
    }

    void tick(num delta){
        walk(delta);
    }

    void physTick(int event, dynamic payload){
        notify(EntityNotifications.NF_PLAYER_CAMERA_UPDATE, null);
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
        if(keybindings == null) return;
        Vector3 change = new Vector3.all(0.0);
        if(keybindings["walk_forwards"]["down"] == true){
            change.x += Math.cos(radians(entity.rotation.y - 90.0));
            change.z += Math.sin(radians(entity.rotation.y - 90.0));
        }
        if(keybindings["walk_backwards"]["down"] == true){
            change.x += Math.cos(radians(entity.rotation.y + 90.0));
            change.z += Math.sin(radians(entity.rotation.y + 90.0));
        }
        if(keybindings["walk_right"]["down"] == true){
            change.x += Math.cos(radians(entity.rotation.y));
            change.z += Math.sin(radians(entity.rotation.y));
        }
        if(keybindings["walk_left"]["down"] == true){
            change.x += Math.cos(radians(entity.rotation.y + 180.0));
            change.z += Math.sin(radians(entity.rotation.y + 180.0));
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

    List<SceneObject> getEntitiesBelowPlayer(){
        List<SceneObject> entitiesBelowPlayer = new List<SceneObject>();
        double playerPos = MathUtils.roundTo(entity.sceneAttachment["position"]["y"].toDouble() - this.playerWidth, 100.0);
        for(SceneObject e in entity.game.world.attachedEntities){
            if(e != null && !(e is Light)){
                if(MathUtils.roundTo(e.sceneAttachment["geometry"]["boundingBox"]["min"]["y"].toDouble(), 100.0) <= playerPos){
                    entitiesBelowPlayer.add(e);
                }
            }
        }
        return entitiesBelowPlayer;
    }

}