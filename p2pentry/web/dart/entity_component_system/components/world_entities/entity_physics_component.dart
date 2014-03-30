part of game;

class EntityPhysicsComponent extends EntityComponent {

    // NOTE: THIS COMPONENT WILL ONLY FUNCTION PROPERLY IN CONJUNCTION WITH AN ENTITYMODEL COMPONENT

    String meshType;
    double mass, friction, restitution;

    EntityPhysicsComponent(String this.meshType, double this.mass, double this.friction, double this.restitution);

    void init(){
        JsObject geometry = getify(EntityNotifications.GF_GEOMETRY);
        JsObject material = getify(EntityNotifications.GF_MATERIAL);
        assert(geometry != null && material != null);
        JsObject wrappedMaterial = context["Physijs"].callMethod("createMaterial", [material, this.friction, this.restitution]);
        entity.sceneAttachment = new JsObject(context["Physijs"][this.meshType], [geometry, wrappedMaterial, this.mass]);
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

}