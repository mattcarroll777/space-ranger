class_name Health
extends Node
## Health — generic HP component (composition over inheritance). Add a child
## node named "Health" to any actor to make it damageable; attackers find it
## with get_node_or_null("Health"). The owner decides what death means by
## connecting to died (despawn, ragdoll, mission-complete, …).

signal changed                               # any hp/shield change (HUD bars)
signal damaged(amount: float, remaining: float)
signal died

@export var max_health := 100.0
@export var max_shield := 0.0    # 0 = no shield; damage hits shield first

var current: float
var shield: float

func _ready() -> void:
	current = max_health
	shield = max_shield

func is_alive() -> bool:
	return current > 0.0

func take_damage(amount: float) -> void:
	if not is_alive():
		return  # already dead; don't re-emit died
	var absorbed := minf(shield, amount)
	shield -= absorbed
	current = maxf(current - (amount - absorbed), 0.0)
	changed.emit()
	damaged.emit(amount, current)
	if current == 0.0:
		died.emit()
