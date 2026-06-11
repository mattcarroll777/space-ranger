extends Control
## Hub — the rangers' ship, their persistent home and the front-end's heart.
##
## Placeholder for now: a title and the ship's access points (War Map, Loadout,
## Settings). Grows into a walkable 3D ship later. Party / matchmaking / store
## will live here. See src/hub/README.md.

## Star Map — the deploy/mission-select destination.
@export_file("*.tscn") var star_map_path: String = "res://src/galaxy/star_map/star_map.tscn"

@onready var _star_map_button: Button = %StarMapButton
@onready var _loadout_button: Button = %LoadoutButton
@onready var _settings_button: Button = %SettingsButton

func _ready() -> void:
	_star_map_button.pressed.connect(_on_star_map_pressed)
	_loadout_button.pressed.connect(func() -> void: push_warning("Loadout not built yet"))
	_settings_button.pressed.connect(func() -> void: push_warning("Settings not built yet"))
	_star_map_button.grab_focus()

func _on_star_map_pressed() -> void:
	if not ResourceLoader.exists(star_map_path):
		push_warning("Star Map not built yet: %s" % star_map_path)
		return
	var err := get_tree().change_scene_to_file(star_map_path)
	if err != OK:
		push_error("Failed to load Star Map (error %d)" % err)
