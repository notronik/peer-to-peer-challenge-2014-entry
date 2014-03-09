part of p2pentry;

abstract class Entity {

    Vector3 position = new Vector3.all(0.0), rotation = new Vector3.all(0.0);
    JsObject entityMesh;
    bool isAttachedToScene = false;

    Entity(Vector3 position, Vector3 rotation){
        if(position != null) this.position = position;
        if(rotation != null) this.rotation = rotation;
    }

    void postConstructor(){
        updatePosition();
        updateRotation();
    }

    void updatePosition(){
        entityMesh["position"]["x"] = position.x;
        entityMesh["position"]["y"] = position.y;
        entityMesh["position"]["z"] = position.z;
    }

    void updateRotation(){
        entityMesh["rotation"]["x"] = radians(rotation.x);
        entityMesh["rotation"]["y"] = radians(rotation.y);
        entityMesh["rotation"]["z"] = radians(rotation.z);
    }

    void tick(num delta);
}