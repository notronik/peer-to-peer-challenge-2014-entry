library game;

import "dart:html";
import "dart:async";
import "dart:js";
import "dart:math" as Math;
import "dart:convert";
import "package:vector_math/vector_math.dart";

part "game.dart";
part "math_utils.dart";

// Entity Component System
part "entity_component_system/csentity.dart";
part "entity_component_system/entity_component.dart";
part "entity_component_system/entity_notifications.dart";
part "entity_component_system/entity_factory.dart";
part "entity_component_system/components/general/entity_shadow_component.dart";
part "entity_component_system/components/player/player_input_component.dart";
part "entity_component_system/components/player/player_physics_component.dart";
part "entity_component_system/components/player/player_camera_component.dart";
// WORK IN PROGRESS
part "entity_component_system/components/world_entities/entity_model_component.dart";
part "entity_component_system/components/world_entities/entity_physics_component.dart";
part "entity_component_system/components/world_entities/entity_light_component.dart";

part "world/level_loader.dart";
part "world/world.dart";
part "world/scene_object.dart";
part "world/entity/physics_entity.dart";
part "world/entity/physics_egeom_entity.dart";
part "world/entity/world_entities/crate_entity.dart";
part "world/entity/world_entities/plane_entity.dart";
part "world/entity/world_entities/pipe_entity.dart";
part "world/entity/world_entities/perforated_pipe_entity.dart";
part "world/light/light.dart";
part "world/light/world_lights/ambient_light.dart";
part "world/light/world_lights/directional_light.dart";

part "world/entity/shadow_mixin.dart";

void main() {
    Game g = new Game();
}