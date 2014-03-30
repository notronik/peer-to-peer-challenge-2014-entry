part of game;

class EntityDirectionalLightConfigurationComponent extends EntityComponent {

    num size, mapDim;

    EntityDirectionalLightConfigurationComponent(num this.size, num this.mapDim);

    void init(){
        entity.sceneAttachment["castShadow"] = true;
        entity.sceneAttachment["shadowCameraRight"] = this.size;
        entity.sceneAttachment["shadowCameraLeft"] = -this.size;
        entity.sceneAttachment["shadowCameraTop"] = this.size;
        entity.sceneAttachment["shadowCameraBottom"] = -this.size;
        entity.sceneAttachment["shadowBias"] = 0.00004;
        entity.sceneAttachment["shadowMapWidth"] = this.mapDim;
        entity.sceneAttachment["shadowMapHeight"] = this.mapDim;
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

}