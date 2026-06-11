class_name StarSystemData
extends Resource
## Pure data describing one star system on the galaxy map.
## Static structure comes from src/galaxy/content/galaxy.json.

## Stable unique id (used by GalaxyState + connections). e.g. "sol".
@export var id: String = ""

## Name shown on the map.
@export var display_name: String = "Unknown System"

## Position on the 2D star map, in pixels.
@export var map_position: Vector2 = Vector2.ZERO

## Ids of systems this one is linked to (drawn as travel lanes).
@export var connections: PackedStringArray = PackedStringArray()

## The system's planets (populated at load).
@export var planets: Array[PlanetData] = []

## Active if any of its planets has an alert.
func is_active() -> bool:
	for planet in planets:
		if planet.is_active():
			return true
	return false

## Distinct alert kinds present across the whole system.
func kinds_present() -> Array:
	var kinds: Array = []
	for planet in planets:
		for kind in planet.kinds_present():
			if not kinds.has(kind):
				kinds.append(kind)
	return kinds
