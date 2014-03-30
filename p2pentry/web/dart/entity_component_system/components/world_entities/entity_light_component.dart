part of game;

class EntityLightComponent extends EntityComponent {

    String lightType;
    List<dynamic> predefinedArguments = new List<dynamic>();

    EntityLightComponent(num color, String this.lightType, {List<dynamic> predefinedArguments}){
        if(predefinedArguments != null) this.predefinedArguments = predefinedArguments;
        this.predefinedArguments.insert(0, color);
    }

    void init(){
        entity.sceneAttachment = new JsObject(context["THREE"][this.lightType], predefinedArguments);
        entity.advanceComponentIntitialisation();
    }

    void tick(num delta){

    }

}