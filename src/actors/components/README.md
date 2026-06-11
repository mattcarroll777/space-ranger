# Actor components

Reusable building blocks attached to actors as child nodes (composition over
inheritance). An actor gains an ability by adding the node, not by subclassing.

- **health.gd** (`Health`) — generic HP. Convention: the node is named `Health`
  directly under the actor's collision body; attackers look it up with
  `get_node_or_null("Health")` and call `take_damage()`. The owner connects to
  `died` to decide what death means.
- **weapon.gd** (`Weapon`) — hitscan gun. Owner calls `setup(camera, shooter)`
  once, then `try_fire()`; the component handles cooldown, the camera-center
  ray, damage to `Health`, and placeholder tracer/impact VFX.
