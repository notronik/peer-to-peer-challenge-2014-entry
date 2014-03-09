part of p2pentry;

abstract class PhysicsEntity extends Entity {
    PhysicsEntity(Vector3 position, Vector3 rotation) : super(position, rotation){

    }

    void updatePosition(){
        super.updatePosition();
        entityMesh["__dirtyPosition"] = true;
    }

    void updateRotation(){
        super.updateRotation();
        entityMesh["__dirtyRotation"] = true;
    }

    void tick(num delta);
}