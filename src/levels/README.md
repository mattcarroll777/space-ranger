# Mission levels

A **location is a map**. `levels.json` maps a location id (`<planet_id>_l<N>`) to a
level scene; `mission.gd` loads it on deploy. The level is the PLACE only — terrain,
props, lighting, a `PlayerSpawn` Marker3D. What *happens* there (kaiju, quest, raid…)
comes from the alert on that location and is spawned separately.

Each level is a vertical slice: `levels/<name>/<name>.tscn` (+ local assets later).
Locations not in `levels.json` fall back to the placeholder deploy screen.

- `kronos_flats/` — first level (sys_01_p1_l1, planet Kronos): desert flats,
  ground collision, rocks, temporary OverviewCamera until the playable ranger lands.
