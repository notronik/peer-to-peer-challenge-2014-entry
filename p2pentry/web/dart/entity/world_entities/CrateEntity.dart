part of p2pentry;

class CrateEntity extends PhysicsEntity {
    Vector3 size = new Vector3.all(1.0);
    CrateEntity({Vector3 position, Vector3 rotation, Vector3 size}) : super(position, rotation) {
        if(size != null) this.size = size;
        JsObject geometry = new JsObject(context["THREE"]["CubeGeometry"], [this.size.x, this.size.y, this.size.z]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshBasicMaterial"], [new JsObject(context["THREE"]["MeshBasicMaterial"], [new JsObject.jsify(
                {
                    "color": 0xffffff,
                    "map": context["THREE"]["ImageUtils"].callMethod("loadTexture", ["res/crate.jpg"])
                }
        )])]), 1.0, 0.0]);
        this.entityMesh = new JsObject(context["Physijs"]["BoxMesh"], [geometry, material, 90.0]);
        postConstructor();
    }

    // Overridden
    void tick(num delta){
    }
}