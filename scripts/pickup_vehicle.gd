extends CharacterBody3D
## Simple arcade pickup controller using original primitive geometry.
## Keyboard controls: W/S or arrows accelerate/brake, A/D steer.

const ACCELERATION := 18.0
const MAX_SPEED := 25.0
const REVERSE_SPEED := 9.0
const FRICTION := 10.0
const TURN_RATE := 1.65
var speed := 0.0

func _ready() -> void:
	floor_snap_length = 0.4
	_build_vehicle()

func _build_vehicle() -> void:
	var body_mat := _mat(Color(0.78, 0.16, 0.10))
	var dark_mat := _mat(Color(0.12, 0.13, 0.14))
	var glass_mat := _mat(Color(0.20, 0.42, 0.53))
	_add_box("TruckBody", Vector3(2.1, 0.65, 3.8), Vector3(0, 0.65, 0), body_mat)
	_add_box("Cabin", Vector3(1.7, 0.8, 1.45), Vector3(0, 1.28, -0.45), body_mat)
	_add_box("Windshield", Vector3(1.48, 0.48, 0.08), Vector3(0, 1.35, 0.30), glass_mat)
	_add_box("PickupBed", Vector3(1.55, 0.18, 1.25), Vector3(0, 1.02, -1.28), dark_mat)
	for x in [-0.98, 0.98]:
		for z in [-1.25, 1.25]:
			var wheel := MeshInstance3D.new()
			wheel.name = "Wheel"
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.42
			mesh.bottom_radius = 0.42
			mesh.height = 0.25
			wheel.mesh = mesh
			wheel.rotation_degrees.z = 90
			wheel.position = Vector3(x, 0.42, z)
			wheel.material_override = dark_mat
			add_child(wheel)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.5, 3.6)
	collision.shape = shape
	collision.position = Vector3(0, 0.75, 0)
	add_child(collision)

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.75
	return material

func _add_box(node_name: String, size: Vector3, pos: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)

func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	if throttle > 0.0:
		speed = move_toward(speed, MAX_SPEED, ACCELERATION * delta)
	elif throttle < 0.0:
		speed = move_toward(speed, -REVERSE_SPEED, ACCELERATION * delta)
	else:
		speed = move_toward(speed, 0.0, FRICTION * delta)

	var steer := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	if abs(speed) > 0.5:
		rotation.y -= steer * TURN_RATE * delta * sign(speed)

	var forward := -global_transform.basis.z
	velocity.x = forward.x * speed
	velocity.z = forward.z * speed
	if not is_on_floor():
		velocity.y -= 22.0 * delta
	else:
		velocity.y = -0.5
	move_and_slide()
