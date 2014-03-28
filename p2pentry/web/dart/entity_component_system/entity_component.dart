part of game;

abstract class EntityComponent extends EntityNotifications {

    CSEntity entity;
    String componentID;
    Map<int, Function> nf = new Map<int, Function>();

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

    void receiveNotification(int event, dynamic payload){
        nf[event](event, payload);
    }

}