part of game;

class EntityPlayerInteractionComponent extends EntityComponent {

    Function collisionWithPlayerOnce;

    EntityPlayerInteractionComponent({Function this.collisionWithPlayerOnce});

    void init(){
        if(collisionWithPlayerOnce != null) nf[EntityNotifications.NF_PLAYER_INTERACT_COLLIDE] = handleInteractCollideOnce;
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

    void handleInteractCollideOnce(int event, dynamic payload){
        collisionWithPlayerOnce(payload[0], payload[1], payload[2]);
    }

}