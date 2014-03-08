part of p2pentry;

abstract class Entity {

    Vector3 position = new Vector3.all(0.0), rotation = new Vector3.all(0.0);
    JsObject entityMesh;
    bool isAttachedToScene = false;

    Entity(Vector3 position, Vector3 rotation){
        if(position != null) this.position = position;
        if(rotation != null) this.rotation = rotation;
    }

    void preTick(num delta){
        entityMesh["position"]["x"] = position.x;
        entityMesh["position"]["y"] = position.y;
        entityMesh["position"]["z"] = position.z;
        entityMesh["rotation"]["x"] = rotation.x;
        entityMesh["rotation"]["y"] = rotation.y;
        entityMesh["rotation"]["z"] = rotation.z;

        tick(delta);
    }

    void tick(num delta);
}