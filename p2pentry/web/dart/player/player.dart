part of game;

class Player extends PhysicsEntity with ShadowMixin {

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
    double playerWalkSpeed = 15.0;
    double playerForceSpeed = 900.0;
    double playerJumpSpeed = 35.0;
    double mouseSensitivity = 0.35;

    // Player dimensions
    double playerWidth = 0.5;
    double playerFriction = 1.0;
    double playerRestitution = 0.3;
    double playerMass = 2.0;
    bool lastOnGround = false;

    bool walking = false;
    double ticksJumpThrottled = 0.0;

    static const double MAX_ZOOM = 5.0;
    static const double MIN_ZOOM = 25.0;
    double zoomFactor = ((MAX_ZOOM + MIN_ZOOM) / 2);

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
        },
        "reset" : {
            "key" : KeyCode.ENTER,
            "down" : false,
        }
    };

    Player(Game game, CanvasElement canvas, {Vector3 position, Vector3 rotation}) : super(position, rotation){
        this.game = game;
        this.canvas = canvas;

        camera = new JsObject(context["THREE"]["PerspectiveCamera"], [Player.FOV, canvas.width / canvas.height, Player.ZNEAR, Player.ZFAR]);

        setupPhysics();

        window.onKeyDown.listen(keyDownListener);
        window.onKeyUp.listen(keyUpListener);
        canvas.onMouseMove.listen(mouseMoveListener);
        canvas.onMouseWheel.listen(mouseZoomListener);

        canvas.onClick.listen((MouseClickEvent){
            canvas.requestPointerLock();
        });
        postConstructor();
        this.enableShadows(this.sceneAttachment);
    }

    void setupPhysics(){
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
        this.sceneAttachment = new JsObject(context["Physijs"]["SphereMesh"], [geometry, material, playerMass]);
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

    void mouseZoomListener(WheelEvent event){
        zoomFactor += event.deltaY;
        zoomFactor = zoomFactor.clamp(MAX_ZOOM, MIN_ZOOM);
    }

    void tick(num delta){
        walk(delta);
        if(keybindings["reset"]["down"] == true) teleport(game.world.lastStart);
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
            JsObject linvel = this.sceneAttachment.callMethod("getLinearVelocity");
            this.sceneAttachment.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linvel["x"].toDouble(), 0.0, linvel["z"].toDouble()])]);
            ticksJumpThrottled = 6.0;

            this.sceneAttachment.callMethod("applyCentralImpulse", [new JsObject(context["THREE"]["Vector3"], [0.0, change.y * delta * playerJumpSpeed, 0.0])]);
            change.y = 0.0;
        }
        if(keybindings["fly_up"]["down"] == true){
            change.y += 6;
        }
        if(keybindings["fly_down"]["down"] == true){
            change.y -= 6;
        }
        walking = !(change.x == 0.0 && change.z == 0.0);

        this.sceneAttachment.callMethod("applyCentralForce", [new JsObject(context["THREE"]["Vector3"], [change.x * delta * playerForceSpeed, change.y * delta * playerForceSpeed, change.z * delta * playerForceSpeed])]);
    }

    void physTick(){
        updateCamera();
        // Limit speed of walking
        JsObject linvel = this.sceneAttachment.callMethod("getLinearVelocity");
        Vector3 linearVelocity = new Vector3(linvel["x"].toDouble(), linvel["y"].toDouble(), linvel["z"].toDouble());

        double linearSpeed = linearVelocity.xz.length;
        if(linearSpeed > playerWalkSpeed){
            linearVelocity.x *= playerWalkSpeed / linearSpeed;
            linearVelocity.z *= playerWalkSpeed / linearSpeed;
            this.sceneAttachment.callMethod("setLinearVelocity", [new JsObject(context["THREE"]["Vector3"], [linearVelocity.x, linearVelocity.y, linearVelocity.z])]);
        }
    }

    void look(){
        rotation.x += deltaMouse.y * mouseSensitivity;
        rotation.y += deltaMouse.x * mouseSensitivity;
        rotation.y = cclamp(rotation.y);
        rotation.x = rotation.x.clamp(-89.9, 89.9);
    }

    void updateCamera(){
        JsObject entityPos = sceneAttachment["position"];
        Vector3 workPos = position;
        workPos.x = 0.0;
        workPos.y = Math.sin(radians(rotation.x));
        workPos.z = Math.cos(radians(rotation.x));
        workPos *= zoomFactor;

        Quaternion qrotation = new Quaternion.identity();
        qrotation.setEuler(radians(-rotation.y), 0.0, 0.0);
        Matrix3 rotationMatrix = qrotation.asRotationMatrix();
        workPos = rotationMatrix * workPos;
        workPos.x += entityPos["x"];
        workPos.y += entityPos["y"];
        workPos.z += entityPos["z"];
        position = workPos;

        camera["position"]["x"] = position.x;
        camera["position"]["y"] = position.y;
        camera["position"]["z"] = position.z;
        camera.callMethod("lookAt", [sceneAttachment["position"]]);
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

    bool get onGround {
        JsObject raycaster = new JsObject(context["THREE"]["Raycaster"], [
            sceneAttachment["position"],
            new JsObject(context["THREE"]["Vector3"], [0, -1, 0]),
            0.0,
            10.0
        ]);
        JsArray objects = new JsArray.from(game.world.getEntityMeshes(game.world.getEntitiesBelowPlayer()));
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

    num calculateVelocityFromTime(num time){
        return Math.pow(time, 2) * 60;
    }

    void teleport(Vector3 newLocation){
        this.sceneAttachment["position"].callMethod("set", [newLocation.x, newLocation.y, newLocation.z]);
        this.sceneAttachment["__dirtyPosition"] = true;
    }
}