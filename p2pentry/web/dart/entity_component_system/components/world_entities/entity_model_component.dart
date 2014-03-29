part of game;

class EntityModelComponent extends EntityComponent {

    static const int TY_PREDEFINED = 0;
    static const int TY_EXTERNAL = 1;
    int type = TY_PREDEFINED;
    String relevantData; // Either path or geometry type
    JsObject geometry, material;
    List<dynamic> predefinedArguments;
    Map<String, dynamic> materialArguments;
    EntityPhysicsComponent physicsComponent;

    EntityModelComponent(int this.type, String this.relevantData, {List<dynamic> predefinedArguments, Map<String, dynamic> materialArguments, EntityPhysicsComponent physicsComponent}){
        if(predefinedArguments == null) this.predefinedArguments = new List<dynamic>(); else this.predefinedArguments = predefinedArguments;
        if(materialArguments == null) this.materialArguments = new Map<String, dynamic>(); else this.materialArguments = materialArguments;
        if(physicsComponent != null) this.physicsComponent = physicsComponent;
    }

    void init(){
        this.material = new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject.jsify(this.materialArguments)]);
        if(type == TY_PREDEFINED){
            this.geometry = new JsObject(context["THREE"]["CubeGeometry"], this.predefinedArguments);
            if(physicsComponent == null) continueInitialisation();
        }else if(type == TY_EXTERNAL){
            JsObject loader = new JsObject(context["THREE"]["JSONLoader"]);
            loader.callMethod("load", [this.relevantData, new JsFunction.withThis((x, geometry, material){
                this.geometry = geometry;
                if(physicsComponent == null) continueInitialisation();
            })]);
        }
    }

    void continueInitialisation(){
        entity.sceneAttachment = new JsObject(context["THREE"]["Mesh"], [geometry, material]);
    }

    void tick(num delta){

    }

}