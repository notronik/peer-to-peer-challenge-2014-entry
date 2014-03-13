library game;

import "dart:html";
import "dart:async";
import "dart:js";
import "dart:math" as Math;
import "package:vector_math/vector_math.dart";

part "Game.dart";
part "MathUtils.dart";

part "world/World.dart";
part "world/SceneObject.dart";
part "world/entity/PhysicsEntity.dart";
part "world/entity/world_entities/CrateEntity.dart";
part "world/entity/world_entities/PlaneEntity.dart";
part "world/light/Light.dart";
part "world/light/world_lights/AmbientLight.dart";

part "player/Player.dart";

void main() {
    Game g = new Game();
}