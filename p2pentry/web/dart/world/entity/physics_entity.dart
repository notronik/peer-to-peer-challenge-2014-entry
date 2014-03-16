part of game;

abstract class PhysicsEntity extends SceneObject {
    PhysicsEntity(Vector3 position, Vector3 rotation) : super(position, rotation);

    PhysicsEntity.fromArray(List<dynamic> positional, Map<Symbol, dynamic> named) : super.fromArray(positional, named);

    void postConstructor(){
        super.postConstructor();
        this.sceneAttachment["geometry"].callMethod("computeBoundingBox");
    }

    void updatePosition(){
        super.updatePosition();
        sceneAttachment["__dirtyPosition"] = true;
    }

    void updateRotation(){
        super.updateRotation();
        sceneAttachment["__dirtyRotation"] = true;
    }

    void tick(num delta);
}