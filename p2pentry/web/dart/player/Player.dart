part of p2pentry;

class Player extends PhysicsEntity {

    /*
     * Just because I keep forgetting:
     * Rotation.x = Pitch
     * Rotation.y = Yaw
     * Rotation.z = Roll
     * All in degrees. Radian conversions are made where necessary.
     */

    Game game;

    Vector3 position = new Vector3.all(0.0), rotation = new Vector3.all(0.0);
    Vector2 deltaMouse = new Vector2.all(0.0);

    CanvasElement canvas;
    JsObject camera;

    static const double FOV = 80.0;
    static const double ZNEAR = 0.001;
    static const double ZFAR = 10000.0;
    double playerWalkSpeed = 2.0;
    double playerForceSpeed = 100000.0;
    double playerJumpSpeed = 200.0;
    double mouseSensitivity = 0.35;

    // Player dimensions
    double playerHeight = 1.85;
    double playerEyeDistFromTop = 0.20;
    double playerWidth = 0.60;
    double playerFriction = 0.0;
    double playerRestitution = 0.3;
    double playerMass = 60.0;
    bool lastOnGround = false;

    double ticksNotWalking = 0.0;
    double ticksJumpThrottled = 0.0;

    Map<String, Map<String, dynamic>> keybindings = {
        "walk_forwards" : {
            "key" : KeyCode.W,
            "down" : false,
        },
        "walk_backwards" : {
            "key" : KeyCode.S,
            "down" : false,
        },
        "walk_right" : {
            "key" : KeyCode.D,
            "down" : false,
        },
        "walk_left" : {
            "key" : KeyCode.A,
            "down" : false,
        },
        "walk_jump" : {
            "key" : KeyCode.SPACE,
            "down" : false,
        },
        "fly_up" : {
            "key" : KeyCode.Q,
            "down" : false,
        },
        "fly_down" : {
            "key" : KeyCode.E,
            "down" : false,
        }
    };

    Player(Game game, CanvasElement canvas, {Vector3 position, Vector3 rotation}) : super(position, rotation){
        this.game = game;
        if(position != null) this.position = position;
        if(rotation != null) this.rotation = rotation;
        this.canvas = canvas;

        camera = new JsObject(context["THREE"]["PerspectiveCamera"], [Player.FOV, canvas.width / canvas.height, Player.ZNEAR, Player.ZFAR]);

        setupPhysics();

        window.onKeyDown.listen(keyDownListener);
        window.onKeyUp.listen(keyUpListener);
        canvas.onMouseMove.listen(mouseMoveListener);

        canvas.onClick.listen((MouseClickEvent){
            canvas.requestPointerLock();
        });
        postConstructor();
    }

    void setupPhysics(){
        JsObject geometry = new JsObject(context["THREE"]["CylinderGeometry"], [playerWidth / 2, playerWidth / 2, playerHeight]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [
            new JsObject(context["THREE"]["MeshBasicMaterial"], [new JsObject.jsify({"transparent" : true, "opacity" : 0.0, "visible" : false})]),
            playerFriction,
            playerRestitution
        ]);
        this.entityMesh = new JsObject(context["Physijs"]["CapsuleMesh"], [geometry, material, playerMass]);
        this.entityMesh.callMethod("addEventListener", ["ready", new JsFunction.withThis((a) => deangulate())]);
    }

    void keyDownListener(KeyboardEvent event){
        keybindings.forEach((String key, Map<String, dynamic> val){
            val.forEach((String k, dynamic v){
                if(k == "key" && v == event.keyCode){
                    val["down"] = true;
                }
            });
        });
    }

    void keyUpListener(KeyboardEvent event){
        keybindings.forEach((String key, Map<String, dynamic> val){
            val.forEach((String k, dynamic v){
                if(k == "key" && v == event.keyCode){
                    val["down"] = false;
                }
            });
        });
    }

    void mouseMoveListener(MouseEvent event){
        deltaMouse.x = event.movement.x.toDouble();
        deltaMouse.y = event.movement.y.toDouble();

        look();
    }

    void tick(num delta){
        walk(delta);

        camera["position"]["x"] = entityMesh["position"]["x"];
        camera["position"]["y"] = entityMesh["position"]["y"] + (playerHeight / 2) - playerEyeDistFromTop;
        camera["position"]["z"] = entityMesh["position"]["z"];
    }

    void walk(num delta){
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
            JsObject linvel = this.entityMesh.callMethod("getLinearVelocity");
            this.entityMesh.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linvel["x"].toDouble(), 0.0, linvel["z"].toDouble()])]);
            ticksJumpThrottled = 6.0;

            this.entityMesh.callMethod("applyCentralImpulse", [new JsObject(context["THREE"]["Vector3"], [0.0, change.y * delta * playerJumpSpeed, 0.0])]);
            change.y = 0.0;
        }
        if(keybindings["fly_up"]["down"] == true){
            change.y += 1;
        }
        if(keybindings["fly_down"]["down"] == true){
            change.y -= 1;
        }
        if(change.x == 0.0 && change.z == 0.0) ticksNotWalking+=delta/0.008; else ticksNotWalking = 0.0;

        this.entityMesh.callMethod("applyCentralForce", [new JsObject(context["THREE"]["Vector3"], [change.x * delta * playerForceSpeed, change.y * delta * playerForceSpeed, change.z * delta * playerForceSpeed])]);
    }

    void physTick(){
        // Limit speed of walking
        JsObject linvel = this.entityMesh.callMethod("getLinearVelocity");
        Vector3 linearVelocity = new Vector3(linvel["x"].toDouble(), linvel["y"].toDouble(), linvel["z"].toDouble());

        double linearSpeed = linearVelocity.xz.length;
        if(ticksNotWalking > 16.0){
            this.entityMesh.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [0.0, linearVelocity.y, 0.0])]);
            // TODO: DAMPING
//            this.entityMesh.callMethod("setDamping", [new JsObject(context["THREE"]["Vector3"], [
//                                                                                                        new JsObject(context["THREE"]["Vector3"], [1000.0, 0.0, 1000.0]),
//                                                                                                        new JsObject(context["THREE"]["Vector3"], [0.0, 0.0, 0.0])
//                                                                                                        ])]);
        }else if(linearSpeed > playerWalkSpeed){
            linearVelocity.x *= playerWalkSpeed / linearSpeed;
            linearVelocity.z *= playerWalkSpeed / linearSpeed;
            this.entityMesh.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linearVelocity.x, linearVelocity.y, linearVelocity.z])]);
        }
    }

    void look(){
        rotation.x += deltaMouse.y * mouseSensitivity;
        rotation.y += deltaMouse.x * mouseSensitivity;
        rotation.y = cclamp(rotation.y);
        rotation.x = rotation.x.clamp(-90.0, 90.0);
        Quaternion qrotation = new Quaternion.identity();
        qrotation.setEuler(radians(-rotation.y), radians(-rotation.x), 0.0);

        Matrix3 rotationMatrix = qrotation.asRotationMatrix();
        JsObject threeMatrix = new JsObject(context["THREE"]["Matrix4"], [
           rotationMatrix.row0.x, rotationMatrix.row0.y, rotationMatrix.row0.z, 0.0,
           rotationMatrix.row1.x, rotationMatrix.row1.y, rotationMatrix.row1.z, 0.0,
           rotationMatrix.row2.x, rotationMatrix.row2.y, rotationMatrix.row2.z, 0.0,
           0.0, 0.0, 0.0, 1.0
        ]);

        camera["rotation"].callMethod("setFromRotationMatrix", [threeMatrix]);
    }

    double cclamp(double val){
        if(val < 0.0){
            return 360.0 + val;
        }
        if(val > 360.0){
            return val - 360.0;
        }
        return val;
    }

    void deangulate(){
        this.entityMesh.callMethod("setAngularFactor", [new JsObject(context["THREE"]["Vector3"], [0, 0, 0])]);
    }

    bool get onGround {
        JsObject raycaster = new JsObject(context["THREE"]["Raycaster"], [
            entityMesh["position"],
            new JsObject(context["THREE"]["Vector3"], [0, -1, 0]),
            0.0,
            (playerHeight / 2) + 10.0
        ]);
        JsArray objects = new JsArray.from(game.world.getEntityMeshes(game.world.getEntitiesBelowPlayer()));
        JsArray result = raycaster.callMethod("intersectObjects", [objects, false]);
        if(result.length > 0){
            double distance = MathUtils.roundTo(result.elementAt(0)["distance"] - (playerHeight / 2.0), 100.0);
            lastOnGround = distance == 0.0;
            return distance == 0.0;
        }else{
            lastOnGround = false;
            return false;
        }
    }
}