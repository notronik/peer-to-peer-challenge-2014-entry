part of game;

class World {

    Game game;
    JsObject scene;
    List<CSEntity> attachedEntities = new List<CSEntity>();

    Vector3 lastStart = new Vector3.all(0.0), lastFinish = new Vector3.all(0.0);

    World(Game this.game){
        scene = new JsObject(context["Physijs"]["Scene"]);
        scene.callMethod("addEventListener", ["update", new JsFunction.withThis((a) => game.player.notify(EntityNotifications.NF_PLAYER_PHYSICS_TICK, null))]);
    }

    void attach(CSEntity entity){
        entity.isAttachedToScene = true;
        scene.callMethod("add", [entity.sceneAttachment]);
        attachedEntities.add(entity);
    }

    void detach(CSEntity entity){
        entity.isAttachedToScene = false;
        scene.callMethod("remove", [entity.sceneAttachment]);
        attachedEntities.remove(entity);
    }

    void tick(num delta){
        for(CSEntity entity in attachedEntities){
            entity.tick(delta);
        }
    }

    List<JsObject> getEntityMeshes(List<CSEntity> entities){
        List<JsObject> objects = new List<JsObject>();
        for(CSEntity e in entities){
            objects.add(e.sceneAttachment);
        }
        return objects;
    }

    List<CSEntity> getEntitiesOfType(int type){
        List<CSEntity> entities = new List<CSEntity>();
        for(CSEntity e in attachedEntities){
            if(e.type == type){
                entities.add(e);
            }
        }
        return entities;
    }

    CSEntity getEntityByMesh(JsObject mesh, List<CSEntity> from){
        for(CSEntity e in from){
            if(e.sceneAttachment == mesh){
                return e;
            }
        }
        return null;
    }
}