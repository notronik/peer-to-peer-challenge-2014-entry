part of game;

class AmbientLight extends Light {
    AmbientLight(num color) : super (null, null, color){
        init();
    }

    AmbientLight.fromArray(List<dynamic> positional, Map<Symbol, dynamic> named) : super.fromArray(positional, named){
        init();
    }

    void init(){
        this.sceneAttachment = new JsObject(context["THREE"]["AmbientLight"], [this.color]);
    }

    void tick(num delta){}
    void postConstructor(){}
}