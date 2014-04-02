part of game;

class EntityFactory {
    static CSEntity createPlayer({Vector3 position}){
        if(position == null) position = new Vector3.all(0.0);
        return new CSEntity(Game._game, [
            new PlayerPhysicsComponent(),
            new PlayerInputComponent(),
            new PlayerCameraComponent(),
            new EntityShadowComponent(true, true)
        ], position);
    }

    static CSEntity createAmbientLight(List<dynamic> positional, Map<Symbol, dynamic> named){
        return new CSEntity(Game._game, [
            new EntityLightComponent(positional[0], "AmbientLight"),
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createDirectionalLight(List<dynamic> positional, Map<Symbol, dynamic> named){
        return new CSEntity(Game._game, [
            new EntityLightComponent(positional[0], "DirectionalLight"),
            new EntityDirectionalLightConfigurationComponent(positional[1], Math.pow(2.0, 13))
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createCrate(List<dynamic> positional, Map<Symbol, dynamic> named){
        Vector3 n_size = new Vector3.all(1.0);
        if(named[new Symbol("size")] != null) n_size = named[new Symbol("size")];
        return new CSEntity(Game._game, [
            new EntityModelComponent(EntityModelComponent.TY_PREDEFINED, "CubeGeometry",
                    predefinedArguments: [n_size.x, n_size.y, n_size.y],
                    materialArguments: {
                        "color" : 0xffffff,
                        "_texture" : "res/crate.png"
                    },
                    physicsComponent: new EntityPhysicsComponent("BoxMesh", 2.0, 1.0, 0.0)),
            new EntityShadowComponent(true, true)
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createPlane(List<dynamic> positional, Map<Symbol, dynamic> named){
        Vector2 n_size = new Vector2(100.0, 100.0);
        const double PLANE_THICKNESS = 0.0009;
        if(named[new Symbol("size")] != null) n_size = named[new Symbol("size")];
        return new CSEntity(Game._game, [
            new EntityModelComponent(EntityModelComponent.TY_PREDEFINED, "CubeGeometry",
                    predefinedArguments: [n_size.x, PLANE_THICKNESS, n_size.y],
                    materialArguments: {
                        "color" : 0x53b0fe,
                        "ambient" : 0x53b0fe
                    },
                    physicsComponent: new EntityPhysicsComponent("BoxMesh", 0.0, 1.0, 0.0)),
            new EntityShadowComponent(false, true)
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createPipe(List<dynamic> positional, Map<Symbol, dynamic> named){
        List<Vector3> a_points;
        num a_radius, n_segments = 100, n_radiusSegments = 20;
        bool n_closed = false, n_debug = false;

        a_points = positional[0];
        a_radius = positional[1];
        if(named[new Symbol("segments")] != null) n_segments = named[new Symbol("segments")];
        if(named[new Symbol("radiusSegments")] != null) n_radiusSegments = named[new Symbol("radiusSegments")];
        if(named[new Symbol("closed")] != null) n_closed = named[new Symbol("closed")];
        if(named[new Symbol("debug")] != null) n_debug = named[new Symbol("debug")];

        List<JsObject> jpoints = new List<JsObject>();
        for(Vector3 p in a_points){
            jpoints.add(new JsObject(context["THREE"]["Vector3"], [p.x, p.y, p.z]));
        }
        JsObject spline = new JsObject(context["THREE"]["SplineCurve3"], [new JsArray.from(jpoints)]);
        JsObject texture = context["THREE"]["ImageUtils"].callMethod("loadTexture", ["res/pipe.png"]);
        texture["wrapS"] = context["THREE"]["MirroredRepeatWrapping"];
        texture["wrapT"] = context["THREE"]["MirroredRepeatWrapping"];
        texture["repeat"].callMethod("set", [10, 10]);

        return new CSEntity(Game._game, [
            new EntityModelComponent(EntityModelComponent.TY_PREDEFINED, "TubeGeometry",
                predefinedArguments: [spline, n_segments, a_radius, n_radiusSegments, n_closed, n_debug],
                materialArguments: {
                    "color":0xa9ca38,
                    "ambient":0xa9ca38,
                    "side":context["THREE"]["BackSide"],
                    "map":texture
                },
                physicsComponent: new EntityPhysicsComponent("ConcaveMesh", 0.0, 1.0, 0.0)
            ),
            new EntityShadowComponent(false, true)
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createPerforatedPipe(List<dynamic> positional, Map<Symbol, dynamic> named){
        return new CSEntity(Game._game, [
            new EntityModelComponent(EntityModelComponent.TY_EXTERNAL, "res/models/perf1.js",
                materialArguments: {
                    "color":0xa9ca38,
                    "ambient":0xa9ca38,
                    "side":context["THREE"]["BackSide"]
                },
                physicsComponent: new EntityPhysicsComponent("ConcaveMesh", 0.0, 1.0, 0.0)
            ),
            new EntityShadowComponent(false, true)
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createPipeInsertBASE(List<dynamic> positional, Map<Symbol, dynamic> named, num color, Vector3 scale, EntityComponent interactionComponent){
        return new CSEntity(Game._game, [
            new EntityModelComponent(EntityModelComponent.TY_EXTERNAL, "res/models/insert.js",
                materialArguments: {
                    "color":color,
                    "ambient":color,
                    "side":context["THREE"]["BackSide"]
                }
            ),
            // TODO: Create EntityPlayerInteractionComponent for collisions w/ player
            new EntityScaleComponent(scale),
            new EntityShadowComponent(false, true)
        ], _extractNamedPosition(named), _extractNamedRotation(named));
    }

    static CSEntity createPipeInsertACCEL(List<dynamic> positional, Map<Symbol, dynamic> named){
        return createPipeInsertBASE(positional, named, 0xff5500, new Vector3.all(0.95), null);
    }

    static Vector3 _extractNamedPosition(Map<Symbol, dynamic> named){
        if(named[new Symbol("position")] != null)
            return named[new Symbol("position")];
        else
            return new Vector3.all(0.0);
    }

    static Vector3 _extractNamedRotation(Map<Symbol, dynamic> named){
        if(named[new Symbol("rotation")] != null)
            return named[new Symbol("rotation")];
        else
            return new Vector3.all(0.0);
    }
}