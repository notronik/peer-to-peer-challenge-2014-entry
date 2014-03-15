part of game;

class CrateEntity extends PhysicsEntity with ShadowMixin {
    Vector3 size = new Vector3.all(1.0);
    CrateEntity({Vector3 position, Vector3 rotation, Vector3 size}) : super(position, rotation) {
        if(size != null) this.size = size;
        JsObject geometry = new JsObject(context["THREE"]["CubeGeometry"], [this.size.x, this.size.y, this.size.z]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject(context["THREE"]["MeshBasicMaterial"], [new JsObject.jsify(
                {
                    "color": 0xffffff,
                    "map": context["THREE"]["ImageUtils"].callMethod("loadTexture", ["res/crate.png"])
                }
        )])]), 1.0, 0.0]);
        this.sceneAttachment = new JsObject(context["Physijs"]["BoxMesh"], [geometry, material, 2.0]);
        postConstructor();
        enableShadows(this.sceneAttachment);
    }

    // Overridden
    void tick(num delta){
    }
}