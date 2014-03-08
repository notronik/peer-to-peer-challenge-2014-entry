part of p2pentry;

class Player {

    /*
     * Just because I keep forgetting:
     * Rotation.x = Pitch
     * Rotation.y = Yaw
     * Rotation.z = Roll
     */

    Vector3 position = new Vector3.all(0.0), rotation = new Vector3.all(0.0);
    Vector2 deltaMouse = new Vector2.all(0.0);

    CanvasElement canvas;
    JsObject camera;

    static const double FOV = 80.0;
    static const double ZNEAR = 0.001;
    static const double ZFAR = 10000.0;
    double playerSpeed = 10.0;

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
        "fly_up" : {
            "key" : KeyCode.Q,
            "down" : false,
        },
        "fly_down" : {
            "key" : KeyCode.E,
            "down" : false,
        }
    };

    Player(CanvasElement canvas, {Vector3 position, Vector3 rotation}){
        if(position != null) this.position = position;
        if(rotation != null) this.rotation = rotation;
        this.canvas = canvas;

        camera = new JsObject(context["THREE"]["PerspectiveCamera"], [Player.FOV, canvas.width / canvas.height, Player.ZNEAR, Player.ZFAR]);

        window.onKeyDown.listen(keyDownListener);
        window.onKeyUp.listen(keyUpListener);
        canvas.onMouseMove.listen(mouseMoveListener);

        canvas.onClick.listen((MouseClickEvent){
            canvas.requestPointerLock();
        });
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

        camera["position"]["x"] = position.x;
        camera["position"]["y"] = position.y;
        camera["position"]["z"] = position.z;
    }

    void walk(num delta){
        Vector2 change = new Vector2.all(0.0);
        if(keybindings["walk_forwards"]["down"] == true){
            change.x += Math.cos(radians(rotation.y - 90.0));
            change.y += Math.sin(radians(rotation.y - 90.0));
        }
        if(keybindings["walk_backwards"]["down"] == true){
            change.x += Math.cos(radians(rotation.y + 90.0));
            change.y += Math.sin(radians(rotation.y + 90.0));
        }
        if(keybindings["walk_right"]["down"] == true){
            change.x += Math.cos(radians(rotation.y));
            change.y += Math.sin(radians(rotation.y));
        }
        if(keybindings["walk_left"]["down"] == true){
            change.x += Math.cos(radians(rotation.y + 180.0));
            change.y += Math.sin(radians(rotation.y + 180.0));
        }
        if(keybindings["fly_up"]["down"] == true){
            position.y += playerSpeed * delta;
        }
        if(keybindings["fly_down"]["down"] == true){
            position.y -= playerSpeed * delta;
        }
        change = change.normalize();

        position.x += change.x * delta * playerSpeed;
        position.z += change.y * delta * playerSpeed;
    }

    void look(){
        rotation.x += deltaMouse.y * 0.01;
        rotation.y += deltaMouse.x * 0.01;
        Quaternion qrotation = new Quaternion.identity();
        qrotation.setEuler(-rotation.y, -rotation.x, 0.0);

        Matrix3 rotationMatrix = qrotation.asRotationMatrix();
        JsObject threeMatrix = new JsObject(context["THREE"]["Matrix4"], [
           rotationMatrix.row0.x, rotationMatrix.row0.y, rotationMatrix.row0.z, 0.0,
           rotationMatrix.row1.x, rotationMatrix.row1.y, rotationMatrix.row1.z, 0.0,
           rotationMatrix.row2.x, rotationMatrix.row2.y, rotationMatrix.row2.z, 0.0,
           0.0, 0.0, 0.0, 1.0
        ]);

        camera["rotation"].callMethod("setFromRotationMatrix", [threeMatrix]);
    }

    double cclamp(double val, double min, double max){
        double range = max - min;
        return val < min ? max - abs(val % range) : val > max ? min + abs(val % range) : val;
    }

    double abs(double val){
        return val < 0 ? val * -1.0 : val;
    }

}