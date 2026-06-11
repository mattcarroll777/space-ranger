extends Control
## Mission — deployment screen. If the deployed location has a level registered in
## levels/levels.json it is loaded (a location IS a map) and the info panel becomes
## the PAUSE MENU, shown while the player's mouse look is released (Esc). The world
## keeps running while paused — stays correct for future co-op. Otherwise this is
## the placeholder info screen. Threat/objective spawning lands here next.

const STAR_MAP := "res://src/galaxy/star_map/star_map.tscn"
const LEVEL_REGISTRY := "res://src/levels/levels.json"
const THREAT_REGISTRY := "res://src/actors/threats/threats.json"

var _player: Player

func _ready() -> void:
	if MissionContext.location_id.is_empty():
		# Dev fallback: scene launched directly (not via Deploy) — use the first level.
		MissionContext.set_deployment("Helios", "Kronos", "Location 1", "sys_01_p1_l1",
				"Threat", "Robot Army · Droid Army", Color("ff8c8c"), "robots", "droid_army")
	%System.text = "System:  %s" % MissionContext.system_name
	%Planet.text = "Planet:  %s" % MissionContext.planet_name
	%Location.text = "Location:  %s" % MissionContext.location_name
	%Objective.text = "%s:  %s" % [MissionContext.kind, MissionContext.objective_name]
	%Objective.add_theme_color_override("font_color", MissionContext.objective_color)
	%ReturnButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(STAR_MAP))
	%ReturnButton.grab_focus()
	_load_level()

## Loads the level scene mapped to the deployed location, if any, and turns the
## centered placeholder UI into the pause menu over the 3D view.
func _load_level() -> void:
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEVEL_REGISTRY))
	if not registry is Dictionary:
		push_error("Mission: cannot parse %s" % LEVEL_REGISTRY)
		return
	var scene_path: String = registry.get(MissionContext.location_id, "")
	if scene_path.is_empty():
		return
	var level: Node = load(scene_path).instantiate()
	add_child(level)
	_spawn_player(level)
	_spawn_threats(level)
	$Background.hide()
	$Content/Title.text = "PAUSED"
	$Content/Subtitle.hide()
	%ResumeButton.show()
	%ResumeButton.pressed.connect(func() -> void: _player.set_look_active(true))
	%ReturnButton.release_focus()  # Space is jump now; don't let it trigger the button
	_player.look_changed.connect(func(active: bool) -> void: _set_paused(not active))
	_set_paused(false)

func _set_paused(paused: bool) -> void:
	$PauseDim.visible = paused
	$Content.visible = paused

## Spawns the alert variant's encounter scene (threats.json), if registered.
func _spawn_threats(level: Node) -> void:
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string(THREAT_REGISTRY))
	if not registry is Dictionary:
		push_error("Mission: cannot parse %s" % THREAT_REGISTRY)
		return
	var scene_path: String = registry.get(MissionContext.alert_variant, "")
	if scene_path.is_empty():
		return
	level.add_child(load(scene_path).instantiate())

func _spawn_player(level: Node) -> void:
	_player = preload("res://src/actors/player/player.tscn").instantiate()
	level.add_child(_player)
	var spawn: Node = level.get_node_or_null("PlayerSpawn")
	if spawn is Node3D:
		_player.global_position = (spawn as Node3D).global_position
