part of game;

class PerforatedPipeEntity extends PhysicsEGeomEntity with ShadowMixin {

    static List<dynamic> positional = ["res/models/perf1.js"];

    PerforatedPipeEntity({Vector3 position, Vector3 rotation}) : super("res/models/perf1.js", position, rotation);

    PerforatedPipeEntity.fromArray(List<dynamic> x, Map<Symbol, dynamic> named) : super.fromArray(positional, named); // I would love to add to the positional List, but that's impossible with Dart right now *rage*

    void postGeometryAccumulation(){
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject.jsify({"color":0xa9ca38, "ambient":0xa9ca38, "side":context["THREE"]["BackSide"]})]), 1.0, 0.0]);
        this.sceneAttachment = new JsObject(context["Physijs"]["ConcaveMesh"], [this.geometry, material, 0.0]);

        postConstructor();
        enableShadows(this.sceneAttachment, cast:false, receive:true);
        makeReady();
    }

    void tick(num delta){

    }

}