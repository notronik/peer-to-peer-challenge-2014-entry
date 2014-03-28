part of game;

class World {

    Game game;
    JsObject scene;
    List<SceneObject> attachedEntities = new List<SceneObject>();

    Vector3 lastStart = new Vector3.all(0.0), lastFinish = new Vector3.all(0.0);

    World(Game this.game){
        scene = new JsObject(context["Physijs"]["Scene"]);
        scene.callMethod("addEventListener", ["update", new JsFunction.withThis((a) => game.player.notify(EntityNotifications.NF_PLAYER_PHYSICS_TICK, null))]);
    }

    void attach(SceneObject entity){
        entity.isAttachedToScene = true;
        scene.callMethod("add", [entity.sceneAttachment]);
        attachedEntities.add(entity);
    }

    void attachW(CSEntity entity){
            scene.callMethod("add", [entity.sceneAttachment]);
        }

    void detach(SceneObject entity){
        entity.isAttachedToScene = false;
        scene.callMethod("remove", [entity.sceneAttachment]);
        attachedEntities.remove(entity);
    }

    void tick(num delta){
        for(SceneObject entity in attachedEntities){
            entity.tick(delta);
        }
    }

    List<JsObject> getEntityMeshes(List<SceneObject> entities){
        List<JsObject> objects = new List<JsObject>();
        for(SceneObject e in entities){
            objects.add(e.sceneAttachment);
        }
        return objects;
    }
}