# Mission

The mission RUNNER — glues a place (level) and participants (actors) together at
runtime, driven by MissionContext (set on Deploy from the star map).

`mission.gd`: resolves the deployed location's level via `src/levels/levels.json`,
instantiates it, spawns the player at `PlayerSpawn`, and shrinks the deploy info to
a top-left HUD. Locations with no registered level keep the placeholder screen.
Launching `mission.tscn` directly uses a dev-fallback deployment (Kronos) for fast
iteration.

Next here: threat spawning from the alert (kind/category/variant), objectives,
win/lose. As that lands, split a MissionRunner out of the UI script.
