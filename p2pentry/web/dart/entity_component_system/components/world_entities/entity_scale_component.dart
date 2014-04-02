part of game;

class EntityScaleComponent extends EntityComponent {

    Vector3 scale;

    EntityScaleComponent(Vector3 this.scale);

    void init(){
        entity.sceneAttachment["scale"].callMethod("set", [this.scale.x, this.scale.y, this.scale.z]);
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

}