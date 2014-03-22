part of game;

abstract class PhysicsEGeomEntity extends PhysicsEntity {

    String modelPath;
    JsObject geometry;

    PhysicsEGeomEntity(String this.modelPath, Vector3 position, Vector3 rotation) : super(position, rotation){
        this.init();
    }

    PhysicsEGeomEntity.fromArray(List<dynamic> positional, Map<Symbol, dynamic> named) : super.fromArray(positional, named){
        modelPath = positional[0];
        this.init();
    }

    void init(){
        JsObject loader = new JsObject(context["THREE"]["JSONLoader"]);
        loader.callMethod("load", [this.modelPath, new JsFunction.withThis((x, geometry, material){
            this.geometry = geometry;
            this.postGeometryAccumulation();
        })]);
    }

    void postGeometryAccumulation();

    void tick(num delta);
}