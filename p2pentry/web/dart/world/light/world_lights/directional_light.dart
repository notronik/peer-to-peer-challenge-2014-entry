part of game;

class DirectionalLight extends Light {

    num __intensity = 1.0;

    DirectionalLight(num color, {num intensity: 1.0, Vector3 position}) : super (position, null, color){
        this.__intensity = intensity;
        this.sceneAttachment = new JsObject(context["THREE"]["DirectionalLight"], [color, intensity]);
        this.sceneAttachment["castShadow"] = true;
        num size = 70.0, mapDims = Math.pow(2.0, 13);
        this.sceneAttachment["shadowCameraRight"] = size;
        this.sceneAttachment["shadowCameraLeft"] = -size;
        this.sceneAttachment["shadowCameraTop"] = size;
        this.sceneAttachment["shadowCameraBottom"] = -size;
        this.sceneAttachment["shadowBias"] = 0.00004;
        this.sceneAttachment["shadowMapWidth"] = mapDims;
        this.sceneAttachment["shadowMapHeight"] = mapDims;
//        this.sceneAttachment["shadowCameraVisible"] = true;
        postConstructor();
    }

    num get intensity {
        return this.__intensity;
    }

    void set intensity(num newIntensity){
        this.__intensity = newIntensity;
        sceneAttachment["intensity"] = this.__intensity;
    }

    void tick(num delta){}

    void postConstructor(){
        updatePosition();
    }
}