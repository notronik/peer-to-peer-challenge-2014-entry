part of game;

class PlayerCameraComponent extends EntityComponent {
    CanvasElement canvas;
    JsObject camera;

    Vector3 cameraRotation = new Vector3.all(0.0);

    static const double FOV = 80.0;
    static const double ZNEAR = 0.001;
    static const double ZFAR = 10000.0;

    static const double MAX_ZOOM = 5.0;
    static const double MIN_ZOOM = 25.0;
    double zoomFactor = ((MAX_ZOOM + MIN_ZOOM) / 2);

    PlayerCameraComponent(){
    }

    void init(){
        canvas = entity.game.canvas;

        camera = new JsObject(context["THREE"]["PerspectiveCamera"], [FOV, canvas.width / canvas.height, ZNEAR, ZFAR]);

        nf[EntityNotifications.NF_PLAYER_CAMERA_UPDATE] = (a, b){
//            updateManualCamera(a, b);
            Vector3 playerPosition = new Vector3(
                    entity.sceneAttachment["position"]["x"].toDouble(),
                    entity.sceneAttachment["position"]["y"].toDouble(),
                    entity.sceneAttachment["position"]["z"].toDouble());

            camera.callMethod("lookAt", [entity.sceneAttachment["position"]]);
            updateAutomaticCamera(a, b, playerPosition);
        };
        nf[EntityNotifications.NF_PLAYER_CAMERA_POSITION_UPDATE] = positionUpdate;
        nf[EntityNotifications.NF_SET_CAMERA_ROTATION] = (a, b) => cameraRotation = b;
        nf[EntityNotifications.NF_PLAYER_CAMERA_ZOOM_FACTOR_UPDATE] = (a, b) => zoomFactor = b;
        gf[EntityNotifications.GF_ZOOM_FACTOR] = (a) => zoomFactor;
        gf[EntityNotifications.GF_CAMERA] = (a) => camera;
        gf[EntityNotifications.GF_CAMERA_ROTATION] = (a) => cameraRotation;
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

    void positionUpdate(int event, dynamic payload){
        camera["position"]["x"] = payload.x;
        camera["position"]["y"] = payload.y;
        camera["position"]["z"] = payload.z;
    }

    void updateManualCamera(int event, num delta){
        JsObject entityPos = entity.sceneAttachment["position"];
        Vector3 workPos = entity.position;
        workPos.x = 0.0;
        workPos.y = Math.sin(radians(cameraRotation.x));
        workPos.z = Math.cos(radians(cameraRotation.x));
        workPos *= zoomFactor;

        Quaternion qrotation = new Quaternion.identity();
        qrotation.setEuler(radians(-cameraRotation.y), 0.0, 0.0);
        Matrix3 rotationMatrix = qrotation.asRotationMatrix();
        workPos = rotationMatrix * workPos;
        workPos.x += entityPos["x"];
        workPos.y += entityPos["y"];
        workPos.z += entityPos["z"];
        positionUpdate(-1, workPos);
    }

    void updateAutomaticCamera(int event, num delta, Vector3 playerPosition){
        JsObject linvel = entity.sceneAttachment.callMethod("getLinearVelocity");
        Vector3 linearVelocity = new Vector3(linvel["x"].toDouble(), linvel["y"].toDouble(), linvel["z"].toDouble());
        Vector3 movementDirection = linearVelocity.normalized();
        double mfactor = -3.0;


        playerPosition.x += (movementDirection.x * mfactor);
        playerPosition.y += (movementDirection.y * mfactor);
        playerPosition.z += (movementDirection.z * mfactor);
        positionUpdate(-1, playerPosition);
    }

}