part of game;

abstract class SceneObject {

    bool ready = false;
    List<Function> readinessCallbacks = new List<Function>();

    Vector3 position = new Vector3.all(0.0), rotation = new Vector3.all(0.0);
    JsObject sceneAttachment;
    bool isAttachedToScene = false;

    SceneObject(Vector3 position, Vector3 rotation){
        if(position != null) this.position = position;
        if(rotation != null) this.rotation = rotation;
    }

    SceneObject.fromArray(List<dynamic> positional, Map<Symbol, dynamic> named) : this(named[new Symbol("position")], named[new Symbol("rotation")]);

    void postConstructor(){
        updatePosition();
        updateRotation();
    }

    void updatePosition(){
        sceneAttachment["position"]["x"] = position.x;
        sceneAttachment["position"]["y"] = position.y;
        sceneAttachment["position"]["z"] = position.z;
    }

    void updateRotation(){
        sceneAttachment["rotation"]["x"] = radians(rotation.x);
        sceneAttachment["rotation"]["y"] = radians(rotation.y);
        sceneAttachment["rotation"]["z"] = radians(rotation.z);
    }

    void makeReady(){
        ready = true;
        evaluateReadinessCallbacks();
    }

    void isReady(Function callback){
        if(!ready) readinessCallbacks.add(callback);
        else{
            callback();
        }
    }

    void evaluateReadinessCallbacks(){
        if(ready){
            for(Function f in readinessCallbacks){
                f();
            }
            readinessCallbacks.clear();
        }
    }

    void tick(num delta);
}