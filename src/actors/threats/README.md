# Threats

Enemy actors spawned into mission levels. Data-driven like levels:
`threats.json` maps an alert **variant** id (src/alerts/kinds.json) to an
**encounter scene** — the scene decides which actors appear and where.
The mission runner instantiates it after loading the level; actors never
reference levels.

- **droid_army/** — first encounter: four Quaternius mechs (`droid.tscn` is the
  generic shootable robot — Health component, flinch/death anims, `model`
  export picks the mech; `droid_army.tscn` places one of each). No AI yet.
