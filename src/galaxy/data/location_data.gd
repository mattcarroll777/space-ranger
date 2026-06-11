class_name LocationData
extends Resource
## A deployment location on a planet. "Location 1", "Location 2", … for now.
## Its active alerts (threat/quest/raid/…) come from the GM-controlled AlertState.

@export var id: String = ""               # e.g. "sys_06_p2_l1"
@export var display_name: String = "Location"

## Active alerts here: Array of { "kind", "category", "variant" }.
@export var alerts: Array = []

func is_active() -> bool:
	return not alerts.is_empty()
