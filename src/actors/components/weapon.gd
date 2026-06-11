class_name Weapon
extends Node3D
## Weapon — hitscan gun component. Child of a shooter (player now, AI later).
## Fires a ray from the aiming CAMERA through the center crosshair (industry
## standard; a muzzle-origin shot has parallax), applies damage to the target's
## Health component if it has one, and spawns placeholder tracer/impact VFX.
## The owner calls try_fire(); cooldown is handled here.

const FIRE_COOLDOWN := 0.15
const SHOOT_RANGE := 1000.0

@export var damage := 25.0

var _cooldown := 0.0
var _camera: Camera3D
var _exclude: Array[RID] = []

## The shooter wires the component up: which camera aims, who to never hit.
func setup(camera: Camera3D, shooter: CollisionObject3D) -> void:
	_camera = camera
	_exclude = [shooter.get_rid()]

func _process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)

func try_fire() -> void:
	if _cooldown > 0.0 or _camera == null:
		return
	_cooldown = FIRE_COOLDOWN
	var from := _camera.global_position
	var query := PhysicsRayQueryParameters3D.create(
			from, from - _camera.global_basis.z * SHOOT_RANGE)
	query.exclude = _exclude
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var to: Vector3 = hit.position if hit else from - _camera.global_basis.z * 80.0
	# Tracer starts at the character's hand height, not the camera — the camera is
	# already shoulder-offset, so offsetting from it lands way right of the body.
	var muzzle: Vector3 = global_position + global_transform.basis * Vector3(0.15, 1.35, -0.45)
	_spawn_tracer(muzzle, to)
	if hit:
		_spawn_impact(hit.position)
		var health := (hit.collider as Node).get_node_or_null("Health")
		if health is Health:
			health.take_damage(damage)

## Placeholder VFX (tracer + glowing impact) until real weapons/particles land.
func _spawn_tracer(from: Vector3, to: Vector3) -> void:
	var dir := to - from
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	mesh.height = dir.length()
	mesh.material = _glow_material(Color(1.0, 0.9, 0.5))
	var tracer := MeshInstance3D.new()
	tracer.mesh = mesh
	get_tree().current_scene.add_child(tracer)
	tracer.global_position = from + dir * 0.5
	if dir.cross(Vector3.UP).length() > 0.001:
		# Cylinder axis is Y; aim it along the shot.
		tracer.global_transform.basis = Basis.looking_at(dir.normalized(), Vector3.UP) \
				* Basis.from_euler(Vector3(PI / 2.0, 0.0, 0.0))
	get_tree().create_timer(0.08).timeout.connect(tracer.queue_free)

func _spawn_impact(pos: Vector3) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.14
	sphere.height = 0.28
	sphere.material = _glow_material(Color(1.0, 0.6, 0.15))
	var impact := MeshInstance3D.new()
	impact.mesh = sphere
	get_tree().current_scene.add_child(impact)
	impact.global_position = pos
	get_tree().create_timer(0.35).timeout.connect(impact.queue_free)

func _glow_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat
