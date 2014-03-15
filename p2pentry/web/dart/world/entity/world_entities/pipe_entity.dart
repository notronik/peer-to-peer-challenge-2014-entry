part of game;

class PipeEntity extends SceneObject with ShadowMixin {
    List<Vector3> points;
    num radius, segments, radiusSegments;
    bool closed, debug;

    JsObject spline;
    PipeEntity(List<Vector3> this.points, num this.radius, {num this.segments: 100, num this.radiusSegments: 4, bool this.closed: false, bool this.debug: false, Vector3 position, Vector3 rotation}) : super(position, rotation){
        List<JsObject> jpoints = new List<JsObject>();
        for(Vector3 p in this.points){
            jpoints.add(new JsObject(context["THREE"]["Vector3"], [p.x, p.y, p.z]));
        }
        this.spline = new JsObject(context["THREE"]["SplineCurve3"], [new JsArray.from(jpoints)]);
        JsObject geometry = new JsObject(context["THREE"]["TubeGeometry"], [this.spline, segments, radius, radiusSegments, closed, debug]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject.jsify({"color":0x9540f3, "ambient":0x9540f3, "side":context["THREE"]["BackSide"]})]), 1.0, 0.0]);
        this.sceneAttachment =  new JsObject(context["Physijs"]["ConcaveMesh"], [geometry, material, 0.0]);
        postConstructor();
        enableShadows(this.sceneAttachment, receive: true, cast: false);
    }

    void tick(num delta){}
}