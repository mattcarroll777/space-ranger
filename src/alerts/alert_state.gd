extends Node
## AlertState (autoload) — the unified, game-mastered alert layer.
##
## One system for every alert kind (Threat, Quest, Raid, Survival, Arena,
## Bounty…), organised mode -> kind -> category -> variant in kinds.json. The
## GM activates alerts per location in content/active.json. Single authority;
## reload() to re-read (later server-driven). Read by the star map + mission.

signal changed

const KINDS_FILE := "res://src/alerts/kinds.json"
const ACTIVE_FILE := "res://src/alerts/content/active.json"

var _kinds: Dictionary = {}    # kind_id -> { name, color:Color, priority, mode, categories }
var _active: Dictionary = {}   # location_id -> Array of { kind, category, variant }

func _ready() -> void:
	reload()

func reload() -> void:
	_kinds.clear()
	_active.clear()

	var registry := _load_json(KINDS_FILE)
	for mode_id in registry.get("modes", {}):
		var mode: Dictionary = registry["modes"][mode_id]
		for kind_id in mode.get("kinds", {}):
			var kind: Dictionary = mode["kinds"][kind_id]
			_kinds[kind_id] = {
				"name": kind.get("name", kind_id),
				"color": Color.html(kind.get("color", "#ffffff")),
				"symbol": kind.get("symbol", "?"),
				"priority": int(kind.get("priority", 0)),
				"mode": mode.get("name", mode_id),
				"categories": kind.get("categories", {}),
			}

	for alert in _load_json(ACTIVE_FILE).get("active", []):
		if not alert.has("location"):
			continue
		var loc: String = alert["location"]
		if not _active.has(loc):
			_active[loc] = []
		_active[loc].append({
			"kind": alert.get("kind", ""),
			"category": alert.get("category", ""),
			"variant": alert.get("variant", ""),
		})

	changed.emit()

## All alerts on a location: Array of { kind, category, variant }.
func active_for(location_id: String) -> Array:
	return _active.get(location_id, [])

func has_alert(location_id: String) -> bool:
	return _active.has(location_id)

func kind_color(kind: String) -> Color:
	return _kinds.get(kind, {}).get("color", Color.WHITE)

func kind_name(kind: String) -> String:
	return _kinds.get(kind, {}).get("name", kind)

func kind_symbol(kind: String) -> String:
	return _kinds.get(kind, {}).get("symbol", "?")

func kind_priority(kind: String) -> int:
	return _kinds.get(kind, {}).get("priority", 0)

## Highest-priority kind among a list of kind ids ("" if none).
func top_kind(kinds: Array) -> String:
	var top := ""
	var best := -1
	for kind in kinds:
		var p := kind_priority(kind)
		if p > best:
			best = p
			top = kind
	return top

## "Kaiju · Colossus" — the category + variant display names for an alert.
func display_name(alert: Dictionary) -> String:
	var kind: Dictionary = _kinds.get(alert.get("kind", ""), {})
	var categories: Dictionary = kind.get("categories", {})
	var category: Dictionary = categories.get(alert.get("category", ""), {})
	var category_name: String = category.get("name", alert.get("category", ""))
	var variants: Dictionary = category.get("variants", {})
	var variant_name: String = variants.get(alert.get("variant", ""), {}).get("name", alert.get("variant", ""))
	return "%s · %s" % [category_name, variant_name]

func _load_json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed
	push_warning("AlertState: could not read %s" % path)
	return {}
