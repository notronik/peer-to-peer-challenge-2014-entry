part of game;

class CSEntity {

    Game game;
    bool ready = false;
    List<Function> readinessCallbacks = new List<Function>();

    int type;
    Vector3 _position, _rotation;
    List<EntityComponent> components;
    JsObject sceneAttachment;
    bool isAttachedToScene = false;

    int nextComponentForInitialisation = 0;

    CSEntity(int this.type, Game this.game, List<EntityComponent> this.components, [Vector3 this._position, Vector3 this._rotation]){
        if(this._position == null) this._position = new Vector3.all(0.0);
        if(this._rotation == null) this._rotation = new Vector3.all(0.0);
        advanceComponentIntitialisation();
    }

    void tick(num delta){
        for(EntityComponent c in components){
            c.tick(delta);
        }
    }

    void notify(int event, dynamic payload){
        for(EntityComponent c in components){
            if(c.nf.containsKey(event)){
                c.receiveNotification(event, payload);
            }
        }
    }

    dynamic getify(int event){
        for(EntityComponent c in components){
            if(c.gf.containsKey(event)){
                return c.receiveGetification(event);
            }
        }
        return null;
    }

    Vector3 get position {
        return _position;
    }

    Vector3 get rotation {
        return _rotation;
    }

    void set position(Vector3 newPosition) {
        notify(EntityNotifications.NF_POSITION_UPDATE, newPosition);
        this._position = newPosition;

        this.sceneAttachment["position"].callMethod("set", [newPosition.x, newPosition.y, newPosition.z]);
        this.sceneAttachment["__dirtyPosition"] = true;
    }

    void set rotation(Vector3 newRotation) {
        notify(EntityNotifications.NF_ROTATION_UPDATE, newRotation);
        this._rotation = newRotation;

        this.sceneAttachment["rotation"].callMethod("set", [radians(newRotation.x), radians(newRotation.y), radians(newRotation.z)]);
        this.sceneAttachment["__dirtyPosition"] = true;
    }

    void advanceComponentIntitialisation(){
        if(nextComponentForInitialisation < components.length){
            components[nextComponentForInitialisation++]._init(this);
        }else{
            if(this.sceneAttachment != null) makeReady();
        }
    }

    void makeReady(){
        position = position;
        rotation = rotation;

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

}