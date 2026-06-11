# Galaxy / Star Map

The deploy/mission-select layer, opened from the Hub.

- `data/`     — `StarSystemData`, `PlanetData`, `LocationData` resources. Threat is
                *derived* (a system/planet is threatened if any of its locations are).
- `content/`
  - **`galaxy.json`**  — STATIC structure: systems → planets → location counts. Lanes
                          auto-connect by proximity. Add a star and it appears.
  - Live alerts (threats/quests/raids/…) are NOT here — they live in `src/alerts/`
    (GM-controlled `AlertState`) and are matched onto locations by id.
- `scenes/`   — `star_map.tscn` (pannable 2D map: drag to pan, scroll to zoom).
- `scripts/`  — `star_map.gd`.

Travel state lives in the `GalaxyState` autoload (`src/core/autoloads/`), kept as
a single authority so it can become server-authoritative in co-op.

Next: clicking a system with a threat opens its planets → a Mission.
