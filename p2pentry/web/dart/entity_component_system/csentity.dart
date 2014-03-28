part of game;

class CSEntity {

    Game game;
    Vector3 _position, _rotation;
    List<EntityComponent> components;
    JsObject sceneAttachment;

    CSEntity(Game this.game, List<EntityComponent> this.components, [Vector3 this._position, Vector3 this._rotation]){
        if(this._position == null) this._position = new Vector3.all(0.0);
        if(this._rotation == null) this._rotation = new Vector3.all(0.0);
        for(EntityComponent c in components){
            c._init(this);
        }
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
    }

    void set rotation(Vector3 newRotation) {
        notify(EntityNotifications.NF_ROTATION_UPDATE, newRotation);
        this._rotation = newRotation;
    }

    void teleport(Vector3 newLocation){
        position = newLocation;
        this.sceneAttachment["position"].callMethod("set", [newLocation.x, newLocation.y, newLocation.z]);
        this.sceneAttachment["__dirtyPosition"] = true;
    }

}