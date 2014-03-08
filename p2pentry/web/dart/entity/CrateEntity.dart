part of p2pentry;

class CrateEntity extends Entity {
    Vector3 size = new Vector3.all(1.0);
    CrateEntity({Vector3 position, Vector3 rotation, Vector3 size}) : super(position, rotation) {
        if(size != null) this.size = size;
        JsObject geometry = new JsObject(context["THREE"]["CubeGeometry"], [this.size.x, this.size.y, this.size.z]);
        JsObject material = new JsObject(context["THREE"]["MeshBasicMaterial"], [new JsObject.jsify(
                {
                    "color": 0xffffff,
                    "map": context["THREE"]["ImageUtils"].callMethod("loadTexture", ["res/crate.jpg"])
                }
        )]);
        this.entityMesh = new JsObject(context["THREE"]["Mesh"], [geometry, material]);
    }

    // Overridden
    void tick(num delta){
        rotation.x += 0.01;
        rotation.y += 0.03;
        rotation.z += 0.03;
    }
}