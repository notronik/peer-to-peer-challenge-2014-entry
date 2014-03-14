library game;

import "dart:html";
import "dart:async";
import "dart:js";
import "dart:math" as Math;
import "package:vector_math/vector_math.dart";

part "game.dart";
part "math_utils.dart";

part "world/world.dart";
part "world/scene_object.dart";
part "world/entity/physics_entity.dart";
part "world/entity/world_entities/crate_entity.dart";
part "world/entity/world_entities/plane_entity.dart";
part "world/light/light.dart";
part "world/light/world_lights/ambient_light.dart";

part "player/player.dart";

void main() {
    Game g = new Game();
}