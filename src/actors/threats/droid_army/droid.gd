class_name Droid
extends CharacterBody3D
## Droid — one robot of the droid army. Shootable via the Health component;
## flinches on hit, plays Death and despawns at 0 HP. No AI yet (stands idle) —
## movement/aggro lands next. The mech model is data: any of the Quaternius
## mechs (assets/models/enemies/threats/robots/droid_army/) plugs into `model`.

const MODEL_SCALE := 0.5  # raw mechs are ~6.5 m; scaled to ~3.2 m vs 1.8 m player

@export var model: PackedScene

var _anim: AnimationPlayer

@onready var _health: Health = $Health

func _ready() -> void:
	var rig: Node3D = model.instantiate()
	add_child(rig)
	rig.scale = Vector3.ONE * MODEL_SCALE
	_anim = rig.find_child("AnimationPlayer")
	_anim.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
	_anim.play("Idle")
	_health.damaged.connect(_on_damaged)
	_health.died.connect(_on_died)

func _on_damaged(_amount: float, remaining: float) -> void:
	if remaining > 0.0:
		_anim.play("HitRecieve_1")  # (sic — pack's spelling)
		_anim.queue("Idle")

func _on_died() -> void:
	_anim.play("Death")
	$Collision.set_deferred("disabled", true)  # corpse is not a wall
	get_tree().create_timer(3.0).timeout.connect(queue_free)
