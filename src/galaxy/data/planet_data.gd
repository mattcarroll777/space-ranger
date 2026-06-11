class_name PlanetData
extends Resource
## Pure data for one planet within a star system.

## Stable unique id, e.g. "sys_06_p2".
@export var id: String = ""

## Name shown to the player, e.g. "Sable".
@export var display_name: String = "Unknown Planet"

## Deployment locations on this planet (1-4). Only revealed when active.
@export var locations: Array[LocationData] = []

## Active (selectable on the map) if any of its locations has an alert.
func is_active() -> bool:
	for location in locations:
		if location.is_active():
			return true
	return false

## Distinct alert kinds present across this planet's locations.
func kinds_present() -> Array:
	var kinds: Array = []
	for location in locations:
		for alert in location.alerts:
			if not kinds.has(alert["kind"]):
				kinds.append(alert["kind"])
	return kinds
