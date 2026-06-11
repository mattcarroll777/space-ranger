# Player

The playable ranger — third-person over-the-shoulder (Fortnite-style). Used anywhere
a controllable character is needed: missions now, the walkable Hub and Arena later.

- `player.tscn` — CharacterBody3D: superhero model (from
  `assets/models/playable_characters/humans/`), capsule collision, CameraPivot →
  shoulder-offset SpringArm → Camera.
- `player.gd` — mouse look (X = body yaw, Y = camera pitch), WASD + Shift sprint +
  Space jump, Esc releases the mouse. TPS combat: hold RMB = aim (FOV 75→55, arm
  2.4→1.4, half sensitivity, walk speed), LMB = shoot — a ray from the CAMERA
  through the center crosshair (muzzle-origin has parallax; never do it).
  Animations are attached at runtime from the Universal Animation Library (same
  skeleton, so track paths resolve directly). NOTE: Godot strips the `_Loop`
  suffix on import — names are `Idle`, `Jog_Fwd`, `Sprint`, `Jump`, `Pistol_Idle`.
- `crosshair.gd` — fixed center crosshair (CanvasLayer); gap tightens while aiming.

Spawning: instantiate, add to a level, position at its `PlayerSpawn` Marker3D
(mission.gd does this). The player's camera is `current` and takes over on enter.
