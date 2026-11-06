extends CharacterBody3D
## Lightweight ambient traffic car for the city road.

@export var lane_x: float = 22.0
@export var travel_min_z: float = -101.0
@export var travel_max_z: float = -9.0
@export var travel_speed: float = 6.0
@export var initial_direction: float = 1.0

var direction: float = 1.0

func _ready() -> void:
	direction = 1.0 if initial_direction >= 0.0 else -1.0
	floor_snap_length = 0.3
	_build_car()

func _physics_process(_delta: float) -> void:
	if global_position.z >= travel_max_z:
		direction = -1.0
	elif global_position.z <= travel_min_z:
		direction = 1.0
	rotation.y = PI if direction > 0.0 else 0.0
	velocity = Vector3(0.0, 0.0, direction * travel_speed)
	move_and_slide()

func _mat(color: Color, roughness := 0.72, metallic := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func _add_box(node_name: String, size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _add_cylinder(node_name: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.rotation_degrees.z = 90.0
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _add_torus(node_name: String, inner_radius: float, outer_radius: float, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = outer_radius
	mesh.rings = 20
	mesh.ring_segments = 10
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.rotation_degrees.z = 90.0
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _build_car() -> void:
	var paint_colors: Array[Color] = [
		Color(0.10, 0.35, 0.72),
		Color(0.78, 0.72, 0.55),
		Color(0.16, 0.48, 0.30),
		Color(0.72, 0.18, 0.12)
	]
	var paint := _mat(paint_colors[abs(name.hash()) % paint_colors.size()], 0.24, 0.32)
	paint.clearcoat_enabled = true
	paint.clearcoat = 0.58
	paint.clearcoat_roughness = 0.24
	var glass := _mat(Color(0.08, 0.18, 0.22), 0.16, 0.18)
	var rubber := _mat(Color(0.035, 0.04, 0.045), 0.98)
	var rim := _mat(Color(0.55, 0.60, 0.63), 0.22, 0.86)
	var chrome := _mat(Color(0.72, 0.75, 0.76), 0.2, 0.9)
	var lamp := _mat(Color(1.0, 0.88, 0.58), 0.25)
	var tail_lamp := _mat(Color(0.85, 0.025, 0.018), 0.25)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 1.1, 3.6)
	collision.shape = shape
	collision.position.y = 0.55
	add_child(collision)
	_add_box("Body", Vector3(1.85, 0.62, 3.55), Vector3(0, 0.48, 0), paint)
	_add_box("Cabin", Vector3(1.45, 0.62, 1.55), Vector3(0, 0.95, 0.10), paint)
	_add_box("Windshield", Vector3(1.30, 0.42, 0.06), Vector3(0, 0.97, -0.70), glass)
	_add_box("RearWindow", Vector3(1.28, 0.38, 0.06), Vector3(0, 0.97, 0.90), glass)
	for side in [-1.0, 1.0]:
		for axle_z in [-1.10, 1.10]:
			var wheel_position := Vector3(side * 0.91, 0.29, axle_z)
			_add_torus("Tire_%s_%s" % [str(side), str(axle_z)], 0.19, 0.33, wheel_position, rubber)
			_add_cylinder("Alloy_%s_%s" % [str(side), str(axle_z)], 0.19, 0.23, wheel_position, rim)
			_add_cylinder("Hub_%s_%s" % [str(side), str(axle_z)], 0.055, 0.25, wheel_position, chrome)
		_add_box("Headlight_%s" % str(side), Vector3(0.34, 0.16, 0.06), Vector3(side * 0.58, 0.54, -1.81), lamp)
		_add_box("TailLight_%s" % str(side), Vector3(0.30, 0.17, 0.06), Vector3(side * 0.60, 0.54, 1.81), tail_lamp)
	_add_box("FrontBumper", Vector3(1.96, 0.14, 0.14), Vector3(0, 0.34, -1.84), chrome)
	_add_box("RearBumper", Vector3(1.96, 0.14, 0.14), Vector3(0, 0.34, 1.84), chrome)
