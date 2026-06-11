class_name Player
extends CharacterBody3D
## Player — third-person over-the-shoulder ranger (Fortnite-style TPS).
## Mouse X turns the body, mouse Y pitches the camera; WASD move, Shift sprint,
## Space jump, hold RMB to aim (zoom + slower look + walk speed), LMB to shoot.
## Shooting lives in the Weapon component (src/actors/components/weapon.gd).
## Esc releases the mouse, click recaptures.
## Animations come from the Universal Animation Library, attached at runtime
## (shared skeleton; Godot strips the `_Loop` suffix on import).

const ANIM_RIG := preload("res://assets/models/playable_characters/humans/animations/UAL1_Standard.glb")

const MOUSE_SENS := 0.0015
const AIM_SENS_MULT := 0.5
const JOG_SPEED := 5.0
const SPRINT_SPEED := 8.0
const AIM_SPEED := 3.0
const ACCEL := 12.0
const JUMP_VELOCITY := 4.5
const PITCH_LIMIT := 1.2  # radians (~70°)

const HIP_FOV := 75.0
const AIM_FOV := 55.0
const HIP_ARM := 2.4
const AIM_ARM := 1.4
const ZOOM_LERP := 10.0

const FALL_LIMIT_Y := -15.0  # below this = off the map; respawn

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _anim: AnimationPlayer
var _aiming := false
var _spawn_point := Vector3.ZERO
var _spawn_captured := false

@onready var _model: Node3D = $Model
@onready var _pivot: Node3D = $CameraPivot
@onready var _arm: SpringArm3D = $CameraPivot/SpringArm
@onready var _camera: Camera3D = $CameraPivot/SpringArm/Camera
@onready var _crosshair: Control = $HUD/Crosshair
@onready var _resume_hint: Label = $HUD/ResumeHint
@onready var _weapon: Weapon = $Weapon
@onready var _health: Health = $Health
@onready var _health_bar: ProgressBar = $HUD/StatusBars/HealthBar
@onready var _shield_bar: ProgressBar = $HUD/StatusBars/ShieldBar

## Mouse look does NOT use MOUSE_MODE_CAPTURED: WSLg/Weston's pointer grab is
## unreliable (drops silently, poor relative tracking). Instead we hide the cursor
## and warp it back to screen center every frame, reading the offset as look input.
## Emitted when mouse look engages/releases — the mission shows its pause menu
## while released. The world does NOT pause (stays correct for future co-op).
signal look_changed(active: bool)

var _look_active := true        # false while the cursor is freed (Esc / focus lost)
var _recenter_pending := true   # swallow one frame after (re)gaining the pointer
var _shoot_grace := 0.0         # ignore fire briefly after recapture (the focusing click)

func _ready() -> void:
	_attach_animations()
	_weapon.setup(_camera, self)
	_health.changed.connect(_update_status_bars)
	_update_status_bars()
	set_look_active(true)

## Public: the pause menu's Resume button re-engages look from outside.
func set_look_active(active: bool) -> void:
	_look_active = active
	_recenter_pending = true
	if active:
		_shoot_grace = 0.2
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if active else Input.MOUSE_MODE_VISIBLE
	_crosshair.visible = active
	_resume_hint.visible = not active
	look_changed.emit(active)

func _update_status_bars() -> void:
	_health_bar.max_value = _health.max_health
	_health_bar.value = _health.current
	_shield_bar.max_value = maxf(_health.max_shield, 1.0)
	_shield_bar.value = _health.shield
	_shield_bar.visible = _health.max_shield > 0.0

## Focus is tracked via notifications, NOT get_window().has_focus(): under
## WSLg/Weston the polled focus state can stay false after alt-tabbing back,
## which permanently killed mouse look. Click-to-recapture (_unhandled_input)
## remains the fallback if Weston never delivers FOCUS_IN.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			set_look_active(false)
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			set_look_active(true)
		NOTIFICATION_WM_MOUSE_ENTER:
			_recenter_pending = true
		NOTIFICATION_WM_MOUSE_EXIT:
			# Cursor escaped the window (warp failed under WSLg) — release cleanly
			# instead of leaving look silently dead.
			set_look_active(false)

func _update_look() -> void:
	if not _look_active:
		return
	var center := get_viewport().get_visible_rect().size * 0.5
	if _recenter_pending:
		# Don't read the offset on the first frame back — it would be a huge jump.
		_recenter_pending = false
		Input.warp_mouse(center)
		return
	var offset := get_viewport().get_mouse_position() - center
	if offset != Vector2.ZERO:
		var sens := MOUSE_SENS * (AIM_SENS_MULT if _aiming else 1.0)
		rotate_y(-offset.x * sens)
		_pivot.rotation.x = clampf(_pivot.rotation.x - offset.y * sens,
				-PITCH_LIMIT, PITCH_LIMIT)
		Input.warp_mouse(center)

## The UAL pack shares the base characters' skeleton, so its AnimationPlayer's
## track paths (Armature/Skeleton3D:*) resolve against our model unchanged.
func _attach_animations() -> void:
	var rig := ANIM_RIG.instantiate()
	var source: AnimationPlayer = rig.get_node("AnimationPlayer")
	_anim = AnimationPlayer.new()
	_model.add_child(_anim)
	_anim.root_node = NodePath("..")
	for lib_name in source.get_animation_library_list():
		_anim.add_animation_library(lib_name, source.get_animation_library(lib_name))
	rig.free()
	_anim.playback_default_blend_time = 0.2
	_anim.play("Idle")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_look_active(not _look_active)  # Esc toggles pause/resume
	elif event is InputEventMouseButton and event.pressed and not _look_active:
		set_look_active(true)
		get_viewport().set_input_as_handled()  # the resume click must not also shoot

func _process(delta: float) -> void:
	_update_look()
	var was_aiming := _aiming
	_aiming = Input.is_action_pressed("aim") and _look_active
	if _aiming != was_aiming:
		_crosshair.set_aiming(_aiming)
	_camera.fov = lerpf(_camera.fov, AIM_FOV if _aiming else HIP_FOV, ZOOM_LERP * delta)
	_arm.spring_length = lerpf(_arm.spring_length, AIM_ARM if _aiming else HIP_ARM,
			ZOOM_LERP * delta)
	_shoot_grace = maxf(_shoot_grace - delta, 0.0)
	if Input.is_action_pressed("shoot") and _look_active and _shoot_grace == 0.0:
		_weapon.try_fire()

func _physics_process(delta: float) -> void:
	if not _spawn_captured:
		# First physics frame: the spawner has positioned us by now.
		_spawn_point = global_position
		_spawn_captured = true
	if global_position.y < FALL_LIMIT_Y:
		global_position = _spawn_point
		velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := AIM_SPEED if _aiming \
			else (SPRINT_SPEED if Input.is_action_pressed("sprint") else JOG_SPEED)
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, ACCEL * speed * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, ACCEL * speed * delta)
	move_and_slide()
	_update_animation()

func _update_animation() -> void:
	var next := "Idle"
	var hspeed := Vector2(velocity.x, velocity.z).length()
	if not is_on_floor():
		next = "Jump"
	elif _aiming:
		next = "Walk" if hspeed > 0.5 else "Pistol_Idle"
	elif hspeed > 0.5:
		next = "Sprint" if hspeed > JOG_SPEED + 0.5 else "Jog_Fwd"
	if _anim.current_animation != next:
		_anim.play(next)
