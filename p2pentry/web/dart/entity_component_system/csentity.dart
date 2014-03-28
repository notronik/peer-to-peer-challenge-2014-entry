part of game;

class CSEntity {

    Vector3 position = new Vector3.all(0.0), rotation = new Vector3.all(0.0);
    List<EntityComponent> components;

    CSEntity(List<EntityComponent> this.components){
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

}