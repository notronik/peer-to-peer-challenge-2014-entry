part of game;

class EntityPlayerInteractionComponent extends EntityComponent {

    Function collisionWithPlayer;

    EntityPlayerInteractionComponent({Function this.collisionWithPlayer});

    void init(){
        if(collisionWithPlayer != null) nf[EntityNotifications.NF_PLAYER_INTERACT_COLLIDE] = handleInteractCollide;
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

    void handleInteractCollide(int event, dynamic payload){
        collisionWithPlayer(payload[0], payload[1], payload[2]);
    }

}