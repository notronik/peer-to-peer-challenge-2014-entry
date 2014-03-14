part of game;

class Game {

    JsObject renderer;
    CanvasElement canvas;

    World world;
    Player player;

    Timer tickTimer;
    DateTime tickTimerTime;

    Game(){
        // * PHYSIJS SETUP * //
        context["Physijs"]["scripts"]["worker"] = "js/physijs_worker.js";
        context["Physijs"]["scripts"]["ammo"] = "ammo.small.js";
        // ----------------- //

        canvas = querySelector("#game");

        player = new Player(this, canvas, position: new Vector3(0.0, 2.0, 2.0));

        world = new World(this);
        // Lights first
        world.attach(new AmbientLight(0x7f7f7f));
        world.attach(new DirectionalLight(0xddddddd, position: new Vector3(10.0, 7.0, -2.0).normalize() * 110.0));

        // Player
        world.attach(player);

        // Level
        world.attach(new PlaneEntity());
        world.attach(new CrateEntity(position: new Vector3(0.0, 10.0, 0.0)));
        world.attach(new CrateEntity(position: new Vector3(0.0, 10.9, 0.0)));
        world.attach(new CrateEntity(position: new Vector3(0.0, 11.8, 0.0)));
        world.attach(new CrateEntity(position: new Vector3(0.0, 10.0, -1.0)));
        world.attach(new CrateEntity(position: new Vector3(0.0, 10.9, -1.0)));
        world.attach(new CrateEntity(position: new Vector3(0.0, 10.0, -2.0)));

        renderer = new JsObject(context["THREE"]["WebGLRenderer"], [new JsObject.jsify({"canvas":canvas, "antialias":true})]);
        renderer["shadowMapEnabled"] = true;
        renderer["shadowMapType"] = context["THREE"]["PCFSoftShadowMap"];

        initialiseTimers();
    }

    void render(num delta){
        world.scene.callMethod("simulate");
        renderer.callMethod("render", [world.scene, player.camera]);
        window.animationFrame.then(render, onError:timerError);
    }

    void tick(Timer timer){
        DateTime now = new DateTime.now();
        Duration deltaDura = now.difference(tickTimerTime);
        double delta = deltaDura.inMilliseconds.toDouble() / 1000.0;
        tickTimerTime = now;

        world.tick(delta);
    }

    void initialiseTimers(){
        // Start Tick Timer
        tickTimerTime = new DateTime.now();
        tickTimer = new Timer.periodic(new Duration(milliseconds:8), tick); // 125 ticks = 1 second
        // Start Render 'Timer'
        window.animationFrame.then(render, onError:timerError);
    }

    void timerError(String err){

    }
}