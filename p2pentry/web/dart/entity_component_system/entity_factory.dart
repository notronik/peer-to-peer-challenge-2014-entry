part of game;

class EntityFactory {
    static CSEntity createPlayer({Vector3 position}){
        if(position == null) position = new Vector3.all(0.0);
        return new CSEntity(Game._game, [
            new PlayerPhysicsComponent(),
            new PlayerInputComponent(),
            new PlayerCameraComponent(),
            new EntityShadowComponent(true, true)
        ], position);
    }
}