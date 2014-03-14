part of game;

class AmbientLight extends Light {
    AmbientLight(num color) : super (null, null, color){
        this.sceneAttachment = new JsObject(context["THREE"]["AmbientLight"], [color]);
    }

    void tick(num delta){}
    void postConstructor(){}
}