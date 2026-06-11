# Alerts

The unified, game-mastered alert layer shown on the star map. Replaces the old
separate threat/quest systems with one extensible taxonomy:

```
mode → kind → category → variant       (each KIND has its own colour)
PvE   → Threat (red)  · Quest (gold)
PvPvE → Raid (teal)   · Survival (orange)
PvP   → Arena (purple)· Bounty (pink)
```

- `kinds.json`        — the taxonomy + per-kind colour + priority. Add kinds/
                        categories/variants here (data only, no code).
- `content/active.json` — GM-controlled live alerts: which locations have which
                        kind/category/variant. Edited periodically (later server-driven).
- `alert_state.gd`    — the `AlertState` autoload that loads both. `reload()` to refresh.

A location can hold several alerts. A planet/system is "active" if any of its
locations has an alert; the node is coloured by the highest-priority kind present.
