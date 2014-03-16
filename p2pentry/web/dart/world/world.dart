part of game;

class World {

    Game game;
    JsObject scene;
    List<SceneObject> attachedEntities = new List<SceneObject>();

    Vector3 lastStart = new Vector3.all(0.0), lastFinish = new Vector3.all(0.0);

    World(Game this.game){
        scene = new JsObject(context["Physijs"]["Scene"]);
        scene.callMethod("addEventListener", ["update", new JsFunction.withThis((a) => game.player.physTick())]);
    }

    void attach(SceneObject entity){
        entity.isAttachedToScene = true;
        scene.callMethod("add", [entity.sceneAttachment]);
        attachedEntities.add(entity);
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

    List<SceneObject> getEntitiesBelowPlayer(){
        List<SceneObject> entitiesBelowPlayer = new List<SceneObject>();
        double playerPos = MathUtils.roundTo(game.player.sceneAttachment["position"]["y"].toDouble() - game.player.playerWidth, 100.0);
        for(SceneObject e in attachedEntities){
            if(e != null && !(e is Player || e is Light)){
                if(MathUtils.roundTo(e.sceneAttachment["geometry"]["boundingBox"]["min"]["y"].toDouble(), 100.0) <= playerPos){
                    entitiesBelowPlayer.add(e);
                }
            }
        }
        return entitiesBelowPlayer;
    }

    List<JsObject> getEntityMeshes(List<SceneObject> entities){
        List<JsObject> objects = new List<JsObject>();
        for(SceneObject e in entities){
            objects.add(e.sceneAttachment);
        }
        return objects;
    }
}