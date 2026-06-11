extends Node
## GalaxyState (autoload) — single authority for the galaxy: the STATIC
## structure (systems/planets/locations from galaxy.json, loaded once), the
## LIVE alerts derived onto locations (kept in sync with AlertState), and the
## ship's position. Server-authoritative-ready: the host owns this; clients
## mirror it. Screens (star map) only read from here.

## Emitted when the ship arrives at a new system.
signal traveled(system_id: String)

const GALAXY_FILE := "res://src/galaxy/content/galaxy.json"
const HOME_ID := "sys_01"
const NEIGHBOURS := 2  # lanes per system (to nearest others)

## id -> StarSystemData (static structure + derived alerts).
var systems: Dictionary = {}

## Id of the system the ship is currently at.
var current_system_id: String = ""

func _ready() -> void:
	_load_galaxy()
	_compute_connections()
	_apply_alerts()
	AlertState.changed.connect(_apply_alerts)
	if not systems.has(current_system_id):
		current_system_id = HOME_ID if systems.has(HOME_ID) \
				else (String(systems.keys()[0]) if not systems.is_empty() else "")

func travel_to(system_id: String) -> void:
	if system_id == current_system_id or not systems.has(system_id):
		return
	current_system_id = system_id
	traveled.emit(system_id)

func _load_galaxy() -> void:
	systems.clear()
	if not FileAccess.file_exists(GALAXY_FILE):
		push_error("GalaxyState: galaxy file missing: %s" % GALAXY_FILE)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GALAXY_FILE))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("systems"):
		push_error("GalaxyState: galaxy.json malformed (expected { systems: [...] })")
		return
	for entry in parsed["systems"]:
		var data := StarSystemData.new()
		data.id = entry.get("id", "")
		data.display_name = entry.get("name", "Unknown")
		var pos: Array = entry.get("position", [0, 0])
		data.map_position = Vector2(pos[0], pos[1])
		var planets: Array[PlanetData] = []
		for p in entry.get("planets", []):
			var planet := PlanetData.new()
			planet.id = p.get("id", "")
			planet.display_name = p.get("name", "Unknown")
			planet.locations = _build_locations(planet.id, int(p.get("locations", 1)))
			planets.append(planet)
		data.planets = planets
		systems[data.id] = data

func _build_locations(planet_id: String, count: int) -> Array[LocationData]:
	var locations: Array[LocationData] = []
	for i in count:
		var location := LocationData.new()
		location.id = "%s_l%d" % [planet_id, i + 1]
		location.display_name = "Location %d" % (i + 1)
		locations.append(location)
	return locations

## (Re)derive each location's live alerts from AlertState. Runs on startup and
## whenever AlertState reloads; screens listen to AlertState.changed to redraw.
func _apply_alerts() -> void:
	for data in systems.values():
		for planet in data.planets:
			for location in planet.locations:
				location.alerts = AlertState.active_for(location.id)

func _compute_connections() -> void:
	var all: Array = systems.values()
	for data in all:
		var others: Array = all.filter(func(o: StarSystemData) -> bool: return o.id != data.id)
		others.sort_custom(func(a: StarSystemData, b: StarSystemData) -> bool:
			return data.map_position.distance_squared_to(a.map_position) \
				< data.map_position.distance_squared_to(b.map_position))
		var conns := PackedStringArray()
		for i in mini(NEIGHBOURS, others.size()):
			conns.append(others[i].id)
		data.connections = conns
