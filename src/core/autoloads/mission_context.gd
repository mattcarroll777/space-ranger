extends Node
## MissionContext (autoload) — the deployment chosen on the star map, handed to
## the mission scene. Works for any alert kind (threat / quest / raid / …).
## Server-authoritative-ready: the host sets this, clients mirror it.

var system_name: String = ""
var planet_name: String = ""
var location_name: String = ""
var location_id: String = ""
var kind: String = ""              # display name of the kind, e.g. "Threat", "Raid"
var objective_name: String = ""    # e.g. "Kaiju · Colossus"
var objective_color: Color = Color.WHITE
var alert_category: String = ""    # taxonomy id, e.g. "robots" (drives spawning)
var alert_variant: String = ""     # taxonomy id, e.g. "droid_army"

func set_deployment(p_system: String, p_planet: String, p_location: String,
		p_location_id: String, p_kind: String, p_objective_name: String,
		p_color: Color, p_category := "", p_variant := "") -> void:
	system_name = p_system
	planet_name = p_planet
	location_name = p_location
	location_id = p_location_id
	kind = p_kind
	objective_name = p_objective_name
	objective_color = p_color
	alert_category = p_category
	alert_variant = p_variant
