extends Control
## Main menu — the front-end entry point of Space Rangers.
##
## Minimal by design: a title and a single "Start Game" button. As the
## front-end grows (Deploy, Loadout, Store, Settings) this becomes the first
## screen routed by the screen manager — see src/ui/README.md.

## Scene loaded when the player presses Start Game — the Hub (the rangers' ship).
@export_file("*.tscn") var next_screen_path: String = "res://src/hub/hub.tscn"

@onready var _start_button: Button = %StartButton

func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_start_button.grab_focus()

func _on_start_pressed() -> void:
	if not ResourceLoader.exists(next_screen_path):
		push_warning("Next screen not built yet: %s" % next_screen_path)
		return
	var err := get_tree().change_scene_to_file(next_screen_path)
	if err != OK:
		push_error("Failed to load next screen (error %d)" % err)
