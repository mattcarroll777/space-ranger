extends StaticBody3D
## Target dummy — a shootable practice block proving the Health/Weapon loop:
## reddens as it takes damage, disappears on death. First consumer of the
## Health component; real threats follow the same pattern.

@onready var _health: Health = $Health
@onready var _mesh: MeshInstance3D = $Mesh

func _ready() -> void:
	# Per-instance material copy so one dummy's damage tint doesn't tint them all.
	_mesh.set_surface_override_material(0, _mesh.get_surface_override_material(0).duplicate())
	_health.damaged.connect(_on_damaged)
	_health.died.connect(queue_free)

func _on_damaged(_amount: float, remaining: float) -> void:
	var mat := _mesh.get_surface_override_material(0) as StandardMaterial3D
	mat.albedo_color = Color(0.85, 0.85, 0.9).lerp(
			Color(0.9, 0.15, 0.1), 1.0 - remaining / _health.max_health)
