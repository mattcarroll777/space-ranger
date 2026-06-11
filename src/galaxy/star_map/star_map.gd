extends Control
## Star Map — 2D node map of the galaxy. Pure VIEW: all galaxy data (structure,
## lanes, live alerts) is owned by GalaxyState/AlertState; this screen only
## draws it. Supports drag-to-pan and scroll-to-zoom.

const HUB_PATH := "res://src/hub/hub.tscn"
const MISSION_PATH := "res://src/mission/mission.tscn"

const LANE_COLOR := Color(0.3, 0.7, 1.0, 0.22)
const IDLE_COLOR := Color(0.45, 0.55, 0.65, 1.0)
const BADGE_SIZE := Vector2(48, 48)
const ZOOM_STEP := 1.1
const ZOOM_MIN := Vector2(0.4, 0.4)
const ZOOM_MAX := Vector2(1.6, 1.6)

@onready var _camera: Camera2D = %Camera2D
@onready var _lanes: Node2D = %Lanes
@onready var _systems_layer: Node2D = %Systems
@onready var _info_label: Label = %InfoLabel
@onready var _back_button: Button = %BackButton
@onready var _planet_panel: PanelContainer = %PlanetPanel
@onready var _system_header: Label = %SystemHeader
@onready var _planet_list: VBoxContainer = %PlanetList

var _by_id: Dictionary = GalaxyState.systems   # id -> StarSystemData
var _buttons: Dictionary = {}    # id -> Button (the circle badge)
var _labels: Dictionary = {}     # id -> Label (name under the badge)
var _dragging := false
var _panel_system: StarSystemData = null   # system shown in the planet panel
var _selected_planet_id := ""              # active planet whose locations show

func _ready() -> void:
	_draw_lanes()
	_build_nodes()
	_center_camera()
	_back_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(HUB_PATH))
	GalaxyState.traveled.connect(func(_id: String) -> void: _refresh())
	# Alerts reloading (GM edit / future server push) recolors the map + panel.
	AlertState.changed.connect(func() -> void:
		_refresh()
		_rebuild_panel())
	_refresh()

func _draw_lanes() -> void:
	var drawn: Dictionary = {}
	for data in _by_id.values():
		for other_id in data.connections:
			if not _by_id.has(other_id):
				continue
			var key := "%s|%s" % ([data.id, other_id] if data.id < other_id else [other_id, data.id])
			if drawn.has(key):
				continue
			drawn[key] = true
			var line := Line2D.new()
			line.width = 3.0
			line.default_color = LANE_COLOR
			line.points = PackedVector2Array([data.map_position, _by_id[other_id].map_position])
			_lanes.add_child(line)

func _build_nodes() -> void:
	for data in _by_id.values():
		# Circle badge (clickable) holding the alert symbol.
		var badge := Button.new()
		badge.custom_minimum_size = BADGE_SIZE
		badge.size = BADGE_SIZE
		badge.position = data.map_position - BADGE_SIZE * 0.5
		badge.add_theme_font_size_override("font_size", 20)
		badge.pressed.connect(_on_system_pressed.bind(data.id))
		_systems_layer.add_child(badge)
		_buttons[data.id] = badge

		# Name label centered under the badge.
		var label := Label.new()
		label.size = Vector2(160, 22)
		label.position = data.map_position + Vector2(-80, BADGE_SIZE.y * 0.5 + 4)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		_systems_layer.add_child(label)
		_labels[data.id] = label

func _style_badge(badge: Button, color: Color) -> void:
	var fill := Color(color.r, color.g, color.b, 0.28)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = fill
		style.border_color = color
		style.set_border_width_all(3)
		style.set_corner_radius_all(int(BADGE_SIZE.x * 0.5))  # full radius = circle
		badge.add_theme_stylebox_override(state, style)

func _center_camera() -> void:
	if _by_id.is_empty():
		return
	var center := Vector2.ZERO
	for data in _by_id.values():
		center += data.map_position
	_camera.position = center / _by_id.size()

func _on_system_pressed(id: String) -> void:
	GalaxyState.travel_to(id)
	_panel_system = _by_id[id]
	_selected_planet_id = ""
	_rebuild_panel()

func _rebuild_panel() -> void:
	if _panel_system == null:
		return
	_system_header.text = _panel_system.display_name
	for child in _planet_list.get_children():
		child.queue_free()

	for planet in _panel_system.planets:
		if planet.is_active():
			# Active planets are selectable; choosing one reveals its locations.
			var top := AlertState.top_kind(planet.kinds_present())
			var button := Button.new()
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.text = "%s  %s   [ %s ]" % [AlertState.kind_symbol(top), planet.display_name, AlertState.kind_name(top)]
			button.add_theme_color_override("font_color", AlertState.kind_color(top))
			button.pressed.connect(_on_planet_pressed.bind(planet.id))
			_planet_list.add_child(button)
			if planet.id == _selected_planet_id:
				_add_locations(planet)
		else:
			var label := Label.new()
			label.text = planet.display_name
			_planet_list.add_child(label)

	_planet_panel.visible = true

func _on_planet_pressed(planet_id: String) -> void:
	# Toggle selection so clicking again hides the locations.
	_selected_planet_id = "" if _selected_planet_id == planet_id else planet_id
	_rebuild_panel()

func _add_locations(planet: PlanetData) -> void:
	for location in planet.locations:
		if location.alerts.is_empty():
			var idle := Label.new()
			idle.text = "        %s" % location.display_name
			idle.add_theme_color_override("font_color", IDLE_COLOR)
			_planet_list.add_child(idle)
			continue
		for alert in location.alerts:
			_add_alert_row(planet, location, alert)

func _add_alert_row(planet: PlanetData, location: LocationData, alert: Dictionary) -> void:
	var color := AlertState.kind_color(alert["kind"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var label := Label.new()
	label.text = "    %s %s  —  %s · %s" % [AlertState.kind_symbol(alert["kind"]),
		location.display_name, AlertState.kind_name(alert["kind"]), AlertState.display_name(alert)]
	label.add_theme_color_override("font_color", color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var button := Button.new()
	button.text = "Deploy"
	button.add_theme_color_override("font_color", color)
	button.pressed.connect(_deploy.bind(planet, location, alert))
	row.add_child(button)
	_planet_list.add_child(row)

func _deploy(planet: PlanetData, location: LocationData, alert: Dictionary) -> void:
	MissionContext.set_deployment(
		_panel_system.display_name, planet.display_name, location.display_name,
		location.id, AlertState.kind_name(alert["kind"]),
		AlertState.display_name(alert), AlertState.kind_color(alert["kind"]),
		alert["category"], alert["variant"])
	get_tree().change_scene_to_file(MISSION_PATH)

func _refresh() -> void:
	var current := GalaxyState.current_system_id
	for id in _buttons:
		var badge: Button = _buttons[id]
		var label: Label = _labels[id]
		var data: StarSystemData = _by_id[id]
		var top := AlertState.top_kind(data.kinds_present())

		if top != "":
			badge.text = AlertState.kind_symbol(top)
			_style_badge(badge, AlertState.kind_color(top))
			badge.add_theme_color_override("font_color", Color.WHITE)
		else:
			badge.text = ""
			_style_badge(badge, IDLE_COLOR)

		label.text = ("> %s" % data.display_name) if id == current else data.display_name
		label.add_theme_color_override("font_color",
			Color.WHITE if id == current else Color(0.7, 0.78, 0.86, 1.0))

	var cur: StarSystemData = _by_id.get(current)
	if cur:
		var text := "Current system: %s" % cur.display_name
		var kinds := cur.kinds_present()
		if not kinds.is_empty():
			var names: Array = []
			for kind in kinds:
				names.append(AlertState.kind_name(kind))
			text += "    [ %s ]" % ", ".join(names)
		_info_label.text = text

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = event.pressed
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					_zoom(ZOOM_STEP)
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					_zoom(1.0 / ZOOM_STEP)
	elif event is InputEventMouseMotion and _dragging:
		_camera.position -= event.relative / _camera.zoom

func _zoom(factor: float) -> void:
	_camera.zoom = (_camera.zoom * factor).clamp(ZOOM_MIN, ZOOM_MAX)
