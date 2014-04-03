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
part "entity_component_system/entity_type.dart";
part "entity_component_system/components/common/entity_shadow_component.dart";
part "entity_component_system/components/player/player_input_component.dart";
part "entity_component_system/components/player/player_physics_component.dart";
part "entity_component_system/components/player/player_camera_component.dart";
part "entity_component_system/components/world_entities/entity_model_component.dart";
part "entity_component_system/components/world_entities/entity_physics_component.dart";
part "entity_component_system/components/world_entities/entity_light_component.dart";
part "entity_component_system/components/world_entities/entity_scale_component.dart";
part "entity_component_system/components/world_entities/light_configuration_components/entity_directional_light_configuration_component.dart";

part "world/level_loader.dart";
part "world/world.dart";

void main() {
    Game g = new Game();
}