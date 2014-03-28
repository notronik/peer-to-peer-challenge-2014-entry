part of game;

class PlayerCameraComponent extends EntityComponent {
    CanvasElement canvas;
    JsObject camera;
    JsObject cameraRail;

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
            updateManualCamera(a, b);
            camera.callMethod("lookAt", [entity.sceneAttachment["position"]]);
        };
        nf[EntityNotifications.NF_PLAYER_CAMERA_POSITION_UPDATE] = positionUpdate;
        nf[EntityNotifications.NF_PLAYER_CAMERA_RAIL] = (a, b) => cameraRail = b;
        nf[EntityNotifications.NF_SET_CAMERA_ROTATION] = (a, b) => cameraRotation = b;
        gf[EntityNotifications.GF_ZOOM_FACTOR] = (a) => zoomFactor;
        gf[EntityNotifications.GF_CAMERA] = (a) => camera;
        gf[EntityNotifications.GF_CAMERA_ROTATION] = (a) => cameraRotation;
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

    double dpoint = 0.0;
    Vector3 lastPosition = new Vector3.all(0.0);
    void updateRailCamera(int event, num delta){
        JsObject linvel = entity.sceneAttachment.callMethod("getLinearVelocity");
        Vector3 currentPosition = new Vector3(entity.sceneAttachment["position"]["x"].toDouble(), entity.sceneAttachment["position"]["y"].toDouble(), entity.sceneAttachment["position"]["z"].toDouble());
        Vector3 deltaPosition = currentPosition - lastPosition;
        lastPosition = currentPosition;

        double velocity = deltaPosition.length;
        double length = cameraRail.callMethod("getLength");
        double deltadpoint = velocity / length;
        dpoint += deltadpoint;
        print("$dpoint");
//        JsObject point = cameraRail.callMethod("getPointAt", [dpoint]);
//        camera["position"] = point;
    }

}