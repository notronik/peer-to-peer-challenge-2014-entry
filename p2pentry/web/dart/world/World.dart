part of p2pentry;

class World {

    JsObject scene;
    List<Entity> attachedEntities = new List<Entity>();

    World(Player player){
        scene = new JsObject(context["Physijs"]["Scene"]);
        scene.callMethod("addEventListener", ["update", new JsFunction.withThis((a) => player.physTick())]);
        attachEntity(player);
    }

    void attachEntity(Entity entity){
        entity.isAttachedToScene = true;
        scene.callMethod("add", [entity.entityMesh]);
        attachedEntities.add(entity);
    }

    void detachEntity(Entity entity){
        entity.isAttachedToScene = false;
        scene.callMethod("remove", [entity.entityMesh]);
        attachedEntities.remove(entity);
    }

    void tick(num delta){
        for(Entity entity in attachedEntities){
            entity.tick(delta);
        }
    }
}