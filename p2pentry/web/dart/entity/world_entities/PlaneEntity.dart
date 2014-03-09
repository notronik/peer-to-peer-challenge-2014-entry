part of p2pentry;

class PlaneEntity extends PhysicsEntity {
    static const double PLANE_THICKNESS = 0.0009;
    Vector2 size = new Vector2(100.0, 100.0);
    PlaneEntity({Vector3 position, Vector3 rotation, Vector2 size}) : super(position, rotation) {
        if(size != null) this.size = size;
        JsObject geometry = new JsObject(context["THREE"]["CubeGeometry"], [this.size.x, PLANE_THICKNESS, this.size.y]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshBasicMaterial"], [new JsObject.jsify({"color": 0x53b0fe})]), 1.0, 0.0]);
        this.entityMesh = new JsObject(context["Physijs"]["BoxMesh"], [geometry, material, 0]);
        postConstructor();
    }

    // Overridden
    void tick(num delta){
    }
}