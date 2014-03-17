part of game;

class PipeEntity extends PhysicsEntity with ShadowMixin {
    List<Vector3> points;
    num radius, segments = 100, radiusSegments = 4;
    bool closed = false, debug = false;

    JsObject spline;
    PipeEntity(List<Vector3> this.points, num this.radius, {num this.segments: 100, num this.radiusSegments: 4, bool this.closed: false, bool this.debug: false, Vector3 position, Vector3 rotation}) : super(position, rotation){
        init();
    }

    PipeEntity.fromArray(List<dynamic> positional, Map<Symbol, dynamic> named) : super.fromArray(positional, named){
        this.points = positional[0];
        this.radius = positional[1];
        if(named[new Symbol("segments")] != null) this.segments = named[new Symbol("segments")];
        if(named[new Symbol("radiusSegments")] != null) this.radiusSegments = named[new Symbol("radiusSegments")];
        if(named[new Symbol("closed")] != null) this.closed = named[new Symbol("closed")];
        if(named[new Symbol("debug")] != null) this.debug = named[new Symbol("debug")];
        init();
    }

    void init(){
        List<JsObject> jpoints = new List<JsObject>();
        for(Vector3 p in this.points){
            jpoints.add(new JsObject(context["THREE"]["Vector3"], [p.x, p.y, p.z]));
        }
        this.spline = new JsObject(context["THREE"]["SplineCurve3"], [new JsArray.from(jpoints)]);
        JsObject geometry = new JsObject(context["THREE"]["TubeGeometry"], [this.spline, segments, radius, radiusSegments, closed, debug]);
        JsObject material = context["Physijs"].callMethod("createMaterial", [new JsObject(context["THREE"]["MeshPhongMaterial"], [new JsObject.jsify({"color":0x9540f3, "ambient":0x9540f3, "vertexColors" : context["THREE"]["FaceColors"], "side":context["THREE"]["BackSide"]})]), 1.0, 0.0]);
        this.sceneAttachment = new JsObject(context["Physijs"]["ConcaveMesh"], [geometry, material, 0.0]);

        JsArray faces = this.sceneAttachment["geometry"]["faces"];
        for(int i = 0; i < faces.length; i++){
            faces[i]["color"].callMethod("setHex", [0xff0000]);
        }
        this.sceneAttachment["geometry"]["faces"] = faces;
        this.sceneAttachment["geometry"]["elementsNeedUpdate"] = true;
        this.sceneAttachment["geometry"]["colorsNeedUpdate"] = true;

        postConstructor();
        enableShadows(this.sceneAttachment, receive: true, cast: false);
    }

    void tick(num delta){}
}