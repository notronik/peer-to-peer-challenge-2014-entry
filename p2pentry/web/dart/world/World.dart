part of p2pentry;

class World {

    Game game;
    JsObject scene;
    List<Entity> attachedEntities = new List<Entity>();
    Player player;

    World(Game game, Player player){
        this.game = game;
        this.player = player;
        scene = new JsObject(context["Physijs"]["Scene"]);
        scene.callMethod("addEventListener", ["update", new JsFunction.withThis((a) => this.player.physTick())]);
        attachEntity(this.player);
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

    List<Entity> getEntitiesBelowPlayer(){
        List<Entity> entitiesBelowPlayer = new List<Entity>();
        double playerPos = MathUtils.roundTo(player.entityMesh["position"]["y"] - (player.playerHeight/2), 100.0);
        for(Entity e in attachedEntities){
            if(!(e is Player) && MathUtils.roundTo(e.entityMesh["geometry"]["boundingBox"]["max"]["y"], 100.0) <= playerPos){
                entitiesBelowPlayer.add(e);
            }
        }
        return entitiesBelowPlayer;
    }

    List<JsObject> getEntityMeshes(List<Entity> entities){
        List<JsObject> objects = new List<JsObject>();
        for(Entity e in entities){
            objects.add(e.entityMesh);
        }
        return objects;
    }
}