part of p2pentry;

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

        player = new Player(canvas, position: new Vector3(0.0, 2.0, 2.0));

        world = new World();
        world.attachEntity(player);
        player.deangulate();
        world.attachEntity(new PlaneEntity());
        world.attachEntity(new CrateEntity(position: new Vector3(0.0, 10.0, 0.0)));
        world.attachEntity(new CrateEntity(position: new Vector3(-2.0, 10.0, -2.0)));
        world.attachEntity(new CrateEntity(position: new Vector3(2.0, 10.0, -2.0)));

        renderer = new JsObject(context["THREE"]["WebGLRenderer"], [new JsObject.jsify({"canvas":canvas})]);

        initialiseTimers();
    }

    void render(num delta){
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
        tickTimer = new Timer.periodic(new Duration(milliseconds:8), tick);
        // Start Render 'Timer'
        window.animationFrame.then(render, onError:timerError);
    }

    void timerError(String err){

    }
}