part of game;

class PlayerInputComponent extends EntityComponent {

    double mouseSensitivity = 0.35;

    Vector2 deltaMouse = new Vector2.all(0.0);

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

    PlayerInputComponent(){

    }

    void init(){
        window.onKeyDown.listen(keyDownListener);
        window.onKeyUp.listen(keyUpListener);
        entity.game.canvas.onMouseMove.listen(mouseMoveListener);
        entity.game.canvas.onMouseWheel.listen(mouseZoomListener);

        entity.game.canvas.onClick.listen((MouseClickEvent){
            entity.game.canvas.requestPointerLock();
        });

        gf[EntityNotifications.GF_KEYBINDINGS] = (a) => keybindings;
    }

    void tick(num delta){
        if(keybindings["reset"]["down"] == true) entity.teleport(entity.game.world.lastStart);
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
        double zoomFactor = getify(EntityNotifications.GF_ZOOM_FACTOR);
        if(zoomFactor == null) return;
        zoomFactor += event.deltaY;
        zoomFactor = zoomFactor.clamp(PlayerCameraComponent.MAX_ZOOM, PlayerCameraComponent.MIN_ZOOM);
    }

    void look(){
        Vector3 rotation = getify(EntityNotifications.GF_CAMERA_ROTATION);
        if(rotation == null) return;
        rotation.x += deltaMouse.y * mouseSensitivity;
        rotation.y += deltaMouse.x * mouseSensitivity;
        rotation.y = cclamp(rotation.y);
        rotation.x = rotation.x.clamp(-89.9, 89.9);
        notify(EntityNotifications.NF_SET_CAMERA_ROTATION, rotation);
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

}