part of game;

class Game {

    JsObject renderer;
    CanvasElement canvas;

    LevelLoader levelLoader;
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
        levelLoader = new LevelLoader(this);

        player = new Player(this, canvas, position: new Vector3(0.0, 200.0, 2.0));

        world = new World(this);

        renderer = new JsObject(context["THREE"]["WebGLRenderer"], [new JsObject.jsify({"canvas":canvas, "antialias":true})]);
        renderer["shadowMapEnabled"] = true;
        renderer["shadowMapType"] = context["THREE"]["PCFSoftShadowMap"];

        initialiseTimers();
        levelLoader.load("res/levels/level1.json", (success) => print("callback was $success"));
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