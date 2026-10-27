extends CharacterBody3D
## Original procedural pickup model with mobile-friendly geometry and arcade driving.

const ACCELERATION := 17.0
const MAX_SPEED := 29.0
const REVERSE_SPEED := 10.0
const FRICTION := 9.0
const TURN_RATE := 1.55
var speed := 0.0
var headlights: Array[SpotLight3D] = []

func _ready() -> void:
	floor_snap_length = 0.4
	_build_vehicle()

func _mat(color: Color, roughness := 0.68, metallic := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func _add_box(node_name: String, size: Vector3, pos: Vector3, material: Material, bevel := false) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	if bevel:
		mesh.subdivide_width = 2
		mesh.subdivide_depth = 2
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)
	return node

func _add_cylinder(node_name: String, radius: float, height: float, pos: Vector3, material: Material, rotate_z := 0.0) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	node.mesh = mesh
	node.position = pos
	node.rotation_degrees.z = rotate_z
	node.material_override = material
	add_child(node)
	return node

func _build_vehicle() -> void:
	var paint := _mat(Color(0.72, 0.075, 0.045), 0.28, 0.35)
	var paint_dark := _mat(Color(0.34, 0.035, 0.025), 0.34, 0.25)
	var rubber := _mat(Color(0.035, 0.04, 0.045), 0.92)
	var rim := _mat(Color(0.62, 0.67, 0.70), 0.25, 0.82)
	var glass := _mat(Color(0.10, 0.25, 0.31), 0.18, 0.2)
	var chrome := _mat(Color(0.72, 0.75, 0.76), 0.22, 0.9)
	var lamp := _mat(Color(1.0, 0.88, 0.57), 0.2, 0.1)
	var red_lamp := _mat(Color(0.85, 0.025, 0.018), 0.25, 0.0)
	var black := _mat(Color(0.075, 0.085, 0.09), 0.55, 0.2)

	# Main chassis, bonnet, cab, and open cargo bed.
	_add_box("Chassis", Vector3(1.72, 0.24, 3.75), Vector3(0, 0.47, 0), black)
	_add_box("LowerBody", Vector3(2.02, 0.52, 3.7), Vector3(0, 0.72, 0.02), paint, true)
	_add_box("FrontBonnet", Vector3(1.82, 0.30, 1.03), Vector3(0, 1.00, -1.12), paint, true)
	_add_box("Cabin", Vector3(1.66, 0.82, 1.48), Vector3(0, 1.27, -0.36), paint, true)
	_add_box("Roof", Vector3(1.72, 0.14, 1.55), Vector3(0, 1.73, -0.34), paint_dark, true)
	_add_box("FrontWindshield", Vector3(1.40, 0.48, 0.055), Vector3(0, 1.37, -1.105), glass)
	_add_box("RearWindow", Vector3(1.30, 0.38, 0.055), Vector3(0, 1.37, 0.39), glass)
	for side in [-1.0, 1.0]:
		_add_box("SideWindow_%s" % str(side), Vector3(0.045, 0.43, 0.82), Vector3(side * 0.84, 1.39, -0.36), glass)
		_add_box("DoorHandle_%s" % str(side), Vector3(0.035, 0.06, 0.20), Vector3(side * 1.025, 1.00, -0.32), chrome)
		_add_box("SideMirrorArm_%s" % str(side), Vector3(0.20, 0.045, 0.06), Vector3(side * 0.97, 1.35, -0.93), black)
		_add_box("SideMirror_%s" % str(side), Vector3(0.12, 0.19, 0.16), Vector3(side * 1.08, 1.39, -0.93), chrome)

	# Cargo bed with raised sides and tailgate.
	_add_box("BedFloor", Vector3(1.48, 0.12, 1.20), Vector3(0, 1.02, 1.18), black)
	_add_box("BedLeftWall", Vector3(0.12, 0.35, 1.30), Vector3(-0.77, 1.20, 1.18), paint)
	_add_box("BedRightWall", Vector3(0.12, 0.35, 1.30), Vector3(0.77, 1.20, 1.18), paint)
	_add_box("BedFrontWall", Vector3(1.48, 0.34, 0.10), Vector3(0, 1.20, 0.54), paint)
	_add_box("Tailgate", Vector3(1.50, 0.34, 0.10), Vector3(0, 1.20, 1.82), paint)
	_add_box("FrontGrille", Vector3(0.74, 0.22, 0.055), Vector3(0, 0.82, -1.91), black)
	for grille_line in range(5):
		_add_box("GrilleChrome_%d" % grille_line, Vector3(0.64, 0.018, 0.025), Vector3(0, 0.75 + float(grille_line) * 0.035, -1.95), chrome)
	_add_box("Dashboard", Vector3(1.38, 0.12, 0.28), Vector3(0, 1.12, -0.82), black)
	_add_box("DriverSeat", Vector3(0.54, 0.56, 0.48), Vector3(-0.43, 1.02, 0.05), black)
	_add_box("PassengerSeat", Vector3(0.54, 0.56, 0.48), Vector3(0.43, 1.02, 0.05), black)
	_add_cylinder("SteeringWheel", 0.22, 0.045, Vector3(-0.43, 1.30, -0.78), black, 90.0)
	_add_box("FrontLicensePlate", Vector3(0.48, 0.12, 0.035), Vector3(0, 0.58, -2.035), chrome)
	_add_box("RearLicensePlate", Vector3(0.48, 0.12, 0.035), Vector3(0, 0.58, 2.035), chrome)
	_add_box("FrontBumper", Vector3(2.12, 0.16, 0.18), Vector3(0, 0.48, -1.93), chrome)
	_add_box("RearBumper", Vector3(2.10, 0.15, 0.16), Vector3(0, 0.48, 1.94), chrome)
	for x in [-0.69, 0.69]:
		_add_box("Headlight_%s" % str(x), Vector3(0.34, 0.19, 0.07), Vector3(x, 0.94, -1.91), lamp)
		_add_box("TailLight_%s" % str(x), Vector3(0.20, 0.27, 0.07), Vector3(x, 0.88, 1.91), red_lamp)

		var beam := SpotLight3D.new()
		beam.name = "HeadlightBeam_%s" % str(x)
		beam.position = Vector3(x, 0.94, -1.98)
		beam.light_color = Color(1.0, 0.84, 0.58)
		beam.light_energy = 3.0
		beam.spot_range = 30.0
		beam.spot_angle = 32.0
		beam.shadow_enabled = false
		beam.visible = false
		add_child(beam)
		headlights.append(beam)

	# Four detailed wheels with visible alloy hubs.
	for x in [-1.02, 1.02]:
		for z in [-1.22, 1.25]:
			_add_cylinder("Tire_%s_%s" % [str(x), str(z)], 0.40, 0.28, Vector3(x, 0.43, z), rubber, 90.0)
			_add_cylinder("AlloyHub_%s_%s" % [str(x), str(z)], 0.23, 0.295, Vector3(x * 1.005, 0.43, z), rim, 90.0)
			_add_cylinder("HubCenter_%s_%s" % [str(x), str(z)], 0.075, 0.31, Vector3(x * 1.01, 0.43, z), black, 90.0)
			for spoke in range(6):
				var spoke_angle := float(spoke) * TAU / 6.0
				var spoke := _add_box("WheelSpoke_%s_%s_%d" % [str(x), str(z), spoke], Vector3(0.045, 0.045, 0.035), Vector3(x * 1.01 + cos(spoke_angle) * 0.13, 0.43 + sin(spoke_angle) * 0.13, z), chrome)
				spoke.rotation.z = spoke_angle
	# Wheel arches and side steps add depth to the silhouette.
	for side in [-1.0, 1.0]:
		_add_box("SideStep_%s" % str(side), Vector3(0.13, 0.10, 0.78), Vector3(side * 1.02, 0.47, -0.20), black)
		_add_box("FrontFender_%s" % str(side), Vector3(0.12, 0.18, 0.84), Vector3(side * 1.02, 0.82, -1.22), paint_dark)
		_add_box("RearFender_%s" % str(side), Vector3(0.12, 0.18, 0.84), Vector3(side * 1.02, 0.82, 1.25), paint_dark)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.05, 1.55, 3.75)
	collision.shape = shape
	collision.position = Vector3(0, 0.78, 0)
	add_child(collision)

func _physics_process(delta: float) -> void:
	var accelerate_input := Input.get_action_strength("accelerate")
	var brake_input := Input.get_action_strength("brake")
	if accelerate_input > 0.0:
		speed = move_toward(speed, MAX_SPEED, ACCELERATION * delta)
	elif brake_input > 0.0:
		if speed > 0.15:
			# Braking slows a moving pickup before allowing reverse.
			speed = move_toward(speed, 0.0, 26.0 * delta)
		else:
			speed = move_toward(speed, -REVERSE_SPEED, ACCELERATION * 0.7 * delta)
	else:
		speed = move_toward(speed, 0.0, FRICTION * delta)
	var steer := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var steering_factor := clampf(abs(speed) / MAX_SPEED, 0.18, 1.0)
	if abs(speed) > 0.35:
		rotation.y -= steer * TURN_RATE * steering_factor * delta * sign(speed)
	var forward := -global_transform.basis.z
	velocity.x = forward.x * speed
	velocity.z = forward.z * speed
	if not is_on_floor():
		velocity.y -= 22.0 * delta
	else:
		velocity.y = -0.5
	move_and_slide()
	# Reduce speed on walls or other vehicles, but ignore floor contacts.
	for collision_index in range(get_slide_collision_count()):
		var hit := get_slide_collision(collision_index)
		if absf(hit.get_normal().y) < 0.65:
			speed = move_toward(speed, 0.0, 18.0 * delta)
			break

func _process(_delta: float) -> void:
	var controller := get_tree().get_first_node_in_group("day_night_controller")
	if controller == null:
		return
	var game_seconds := float(controller.get("game_time_seconds"))
	var hour := game_seconds / 3600.0
	var daylight := clampf(sin((hour - 6.0) * PI / 12.0), 0.0, 1.0)
	var should_turn_on := daylight < 0.25
	for headlight in headlights:
		if is_instance_valid(headlight):
			headlight.visible = should_turn_on

func _process(_delta: float) -> void:
	var controller := get_tree().get_first_node_in_group("day_night_controller")
	if controller == null:
		return
	var game_seconds := float(controller.get("game_time_seconds"))
	var hour := game_seconds / 3600.0
	var daylight := clampf(sin((hour - 6.0) * PI / 12.0), 0.0, 1.0)
	var should_turn_on := daylight < 0.55
	for headlight in headlights:
		if is_instance_valid(headlight):
			headlight.visible = should_turn_on
