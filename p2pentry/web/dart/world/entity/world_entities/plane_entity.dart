part of game;

class PlaneEntity extends PhysicsEntity with ShadowMixin {
    static const double PLANE_THICKNESS = 0.0009;
    Vector2 size = new Vector2(100.0, 100.0);
    PlaneEntity({Vector3 position, Vector3 rotation, Vector2 size}) : super(position, rotation) {
        if(size != null) this.size = size;
        init();
    }

    PlaneEntity.fromArray(List<dynamic> positional, Map<Symbol, dynamic> named) : super.fromArray(positional, named) {
        if(named[new Symbol("size")] != null) this.size = named[new Symbol("size")];
        init();
    }

    void init(){
        JsObject geometry = new JsObject(context["THREE"]["CubeGeometry"], [this.size.x, PLANE_THICKNESS, this.size.y]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject.jsify({"color": 0x53b0fe, "ambient": 0x53b0fe})]), 1.0, 0.0]);
        this.sceneAttachment = new JsObject(context["Physijs"]["BoxMesh"], [geometry, material, 0]);
        postConstructor();
        enableShadows(this.sceneAttachment, cast:false);
    }

    // Overridden
    void tick(num delta){
    }
}