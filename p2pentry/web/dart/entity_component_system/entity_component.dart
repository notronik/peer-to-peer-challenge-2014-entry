part of game;

abstract class EntityComponent {

    CSEntity entity;
    String componentID;
    Map<int, Function> nf = new Map<int, Function>(), gf = new Map<int, Function>();

    // The constructor is to feed variables, the factory sorts these out.
    void _init(CSEntity entity){ // This function initialises any component-specific timers, etc.
        this.entity = entity;
        init();
    }

    void init();

    void tick(num delta);

    void notify(int event, dynamic payload){
        entity.notify(event, payload);
    }

    dynamic getify(int event){
        return entity.getify(event);
    }

    void receiveNotification(int event, dynamic payload){
        nf[event](event, payload);
    }

    dynamic receiveGetification(int event){
        return gf[event](event);
    }

}