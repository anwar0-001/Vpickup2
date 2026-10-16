extends Node3D
## Vpickup2: original procedural driving/life-simulation prototype.

const VehicleScript = preload("res://scripts/pickup_vehicle.gd")
const SAVE_PATH := "user://vpickup2_save.cfg"
const HOUSE_PRICE := 1200
const FOOD_PRICE := 25
const CAR_PRICE := 2500

var money: int = 500
var infinite_money := true
var owned_houses: Array[bool] = [false, false, false, false, false, false]
var current_nearby_action := ""
var vehicle: CharacterBody3D
var saved_vehicle_position := Vector3(-24, 0.8, 4)
var saved_vehicle_rotation := Vector3.ZERO
var status_label: Label
var money_label: Label
var action_button: Button
var infinite_button: Button
var world_environment: WorldEnvironment
var touch_actions: Array[String] = ["steer_left", "steer_right", "accelerate", "brake"]

func _ready() -> void:
	_load_game()
	_create_environment()
	_create_world()
	_create_player()
	_create_ui()
	_update_hud()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()

func _exit_tree() -> void:
	_save_game()

func _create_environment() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.light_energy = 1.15
	add_child(sun)
	world_environment = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.79, 0.9)
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = env
	add_child(world_environment)

func _material(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _box(parent: Node3D, label: String, size: Vector3, pos: Vector3, color: Color, collidable := true) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = _material(color)
	parent.add_child(mesh_instance)
	if collidable:
		var body := StaticBody3D.new()
		body.name = label + "_Collision"
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		body.add_child(shape_node)
		body.position = pos
		parent.add_child(body)
	return mesh_instance

func _label_3d(text_value: String, pos: Vector3, color := Color.WHITE) -> void:
	var anchor := Node3D.new()
	anchor.position = pos
	add_child(anchor)
	var label := Label3D.new()
	label.text = text_value
	label.font_size = 32
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	anchor.add_child(label)

func _create_world() -> void:
	_box(self, "Terrain", Vector3(260, 1, 260), Vector3(0, -0.7, 0), Color(0.25, 0.48, 0.22))
	_box(self, "VillageRoad", Vector3(7, 0.12, 105), Vector3(-24, -0.08, 22), Color(0.24, 0.24, 0.23), false)
	_box(self, "CityRoad", Vector3(7, 0.14, 90), Vector3(24, -0.04, -55), Color(0.20, 0.21, 0.22), false)
	_box(self, "ConnectingRoad", Vector3(55, 0.13, 7), Vector3(0, -0.05, -23), Color(0.20, 0.21, 0.22), false)
	_label_3d("VILLAGE", Vector3(-40, 2, 62), Color(1, 0.94, 0.68))
	_label_3d("CITY", Vector3(35, 2, -82), Color(0.72, 0.9, 1))
	_create_village()
	_create_city()
	_create_shops()

func _create_village() -> void:
	for i in range(7):
		var x := -47.0 + float(i % 4) * 11.0
		var z := 18.0 + float(i / 4) * 15.0
		_building("VillageHouse_%d" % i, Vector3(6, 4, 6), Vector3(x, 1.3, z), Color(0.69, 0.48, 0.31), Color(0.37, 0.19, 0.12))
	for i in range(9):
		var x := -70.0 + float(i) * 17.0
		_box(self, "TreeTrunk_%d" % i, Vector3(0.7, 3, 0.7), Vector3(x, 1, 48), Color(0.30, 0.18, 0.09))
		_box(self, "TreeCrown_%d" % i, Vector3(3.4, 3.4, 3.4), Vector3(x, 3.8, 48), Color(0.12, 0.35, 0.13), false)

func _create_city() -> void:
	for i in range(5):
		var z := -78.0 + float(i) * 16.0
		_box(self, "CityCrossStreet_%d" % i, Vector3(64, 0.12, 3), Vector3(24, 0.02, z), Color(0.27, 0.28, 0.29), false)
	for i in range(12):
		var col := i % 4
		var row := int(i / 4)
		var x := 2.0 + float(col) * 15.0
		var z := -87.0 + float(row) * 22.0
		var height := 7.0 + float((i * 7) % 5) * 2.2
		var colors := [Color(0.61,0.64,0.68), Color(0.75,0.68,0.55), Color(0.49,0.57,0.63), Color(0.78,0.77,0.70)]
		_building("CityBuilding_%d" % i, Vector3(8, height, 8), Vector3(x, height / 2.0, z), colors[i % colors.size()], Color(0.25,0.31,0.36))

func _create_shops() -> void:
	_building("CarDealership", Vector3(13, 5, 10), Vector3(42, 2, -48), Color(0.20, 0.46, 0.68), Color(0.08, 0.15, 0.22))
	_label_3d("CAR DEALER\nE: Buy vehicle", Vector3(42, 6, -48), Color(0.85, 0.96, 1))
	_building("FoodMarket", Vector3(10, 4, 9), Vector3(7, 1.5, -48), Color(0.25, 0.58, 0.32), Color(0.12, 0.26, 0.13))
	_label_3d("FOOD MARKET\nE: Buy food", Vector3(7, 5, -48), Color(0.82, 1, 0.82))
	for i in range(6):
		var x := 53.0 + float(i % 3) * 13.0
		var z := -17.0 - float(int(i / 3)) * 18.0
		var house_colors: Array[Color] = [Color(0.84,0.73,0.58), Color(0.71,0.77,0.83), Color(0.81,0.66,0.58)]
		var color: Color = house_colors[i % 3]
		_building("ForSaleHouse_%d" % (i + 1), Vector3(7, 4.5, 7), Vector3(x, 1.55, z), color, Color(0.25,0.19,0.16))
		_label_3d("HOUSE %d\n$%d" % [i + 1, HOUSE_PRICE], Vector3(x, 4.8, z), Color(1,0.94,0.65))

func _building(building_name: String, size: Vector3, pos: Vector3, wall_color: Color, roof_color: Color) -> void:
	_box(self, building_name, size, pos, wall_color)
	_box(self, building_name + "_Roof", Vector3(size.x * 1.12, 0.5, size.z * 1.12), pos + Vector3(0, size.y / 2.0 + 0.25, 0), roof_color, false)
	_box(self, building_name + "_Door", Vector3(0.8, 1.7, 0.12), pos + Vector3(0, -size.y * 0.16, size.z / 2.0 + 0.07), Color(0.22,0.13,0.08), false)
	if size.y > 4.5:
		for side in [-1.0, 1.0]:
			_box(self, building_name + "_Window_" + str(side), Vector3(1.0, 1.0, 0.12), pos + Vector3(side * size.x * 0.25, 0.2, size.z / 2.0 + 0.08), Color(0.36,0.68,0.82), false)

func _create_player() -> void:
	vehicle = VehicleScript.new()
	vehicle.name = "PlayerPickup"
	vehicle.position = saved_vehicle_position
	vehicle.rotation = saved_vehicle_rotation
	add_child(vehicle)
	_attach_camera(vehicle)

func _attach_camera(target_vehicle: Node3D) -> void:
	var camera := Camera3D.new()
	camera.name = "FollowCamera"
	camera.position = Vector3(0, 6.5, 10)
	camera.rotation_degrees = Vector3(-24, 0, 0)
	target_vehicle.add_child(camera)
	camera.current = true

func _create_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "GameUI"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(300, 100)
	layer.add_child(panel)
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	money_label = Label.new()
	money_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(money_label)
	status_label = Label.new()
	status_label.text = "Drive to explore. Work to earn money; visit shops and houses."
	status_label.custom_minimum_size = Vector2(260, 45)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(status_label)
	var controls := HBoxContainer.new()
	vbox.add_child(controls)
	var earn_button := Button.new()
	earn_button.text = "Work +$150"
	earn_button.pressed.connect(_do_work)
	controls.add_child(earn_button)
	infinite_button = Button.new()
	infinite_button.text = "Infinite: ON"
	infinite_button.pressed.connect(_toggle_infinite_money)
	controls.add_child(infinite_button)
	action_button = Button.new()
	action_button.text = "Interact (E)"
	action_button.custom_minimum_size = Vector2(155, 58)
	action_button.anchor_left = 1.0
	action_button.anchor_right = 1.0
	action_button.anchor_top = 1.0
	action_button.anchor_bottom = 1.0
	action_button.offset_left = -175
	action_button.offset_right = -18
	action_button.offset_top = -82
	action_button.offset_bottom = -18
	action_button.pressed.connect(_interact)
	layer.add_child(action_button)
	# On-screen controls are available on phones and tablets; keyboard remains supported.
	_make_hold_button(layer, "◀", "steer_left", Vector2(18, -142), Vector2(66, 62), false)
	_make_hold_button(layer, "▶", "steer_right", Vector2(92, -142), Vector2(66, 62), false)
	_make_hold_button(layer, "▲", "accelerate", Vector2(-166, -214), Vector2(68, 62), true)
	_make_hold_button(layer, "▼", "brake", Vector2(-92, -142), Vector2(68, 62), true)
	var help := Label.new()
	help.text = "WASD / arrows or touch controls"
	help.position = Vector2(18, 126)
	layer.add_child(help)

func _make_hold_button(layer: CanvasLayer, caption: String, action: String, offset: Vector2, button_size: Vector2, right_side: bool) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = button_size
	button.size = button_size
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	if right_side:
		button.anchor_left = 1.0
		button.anchor_right = 1.0
		button.offset_left = offset.x
		button.offset_right = offset.x + button_size.x
	else:
		button.offset_left = offset.x
		button.offset_right = offset.x + button_size.x
	button.offset_top = offset.y
	button.offset_bottom = offset.y + button_size.y
	button.modulate = Color(1, 1, 1, 0.88)
	button.button_down.connect(_press_action.bind(action))
	button.button_up.connect(_release_action.bind(action))
	layer.add_child(button)

func _press_action(action: String) -> void:
	Input.action_press(action)

func _release_action(action: String) -> void:
	Input.action_release(action)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_interact()
	if not is_instance_valid(vehicle):
		return
	var p := vehicle.global_position
	var dealer_distance := Vector2(p.x - 42, p.z + 48).length()
	var food_distance := Vector2(p.x - 7, p.z + 48).length()
	current_nearby_action = ""
	if dealer_distance < 10:
		current_nearby_action = "dealer"
		status_label.text = "Car dealership: interact to buy a pickup ($%d)." % CAR_PRICE
	elif food_distance < 9:
		current_nearby_action = "food"
		status_label.text = "Food market: interact to buy food ($%d)." % FOOD_PRICE
	else:
		for i in range(6):
			var x := 53.0 + float(i % 3) * 13.0
			var z := -17.0 - float(int(i / 3)) * 18.0
			if Vector2(p.x - x, p.z - z).length() < 8.0:
				current_nearby_action = "house_%d" % i
				status_label.text = "House %d: %s. Interact to buy ($%d)." % [i + 1, "Owned" if owned_houses[i] else "For sale", HOUSE_PRICE]
				return

func _update_hud() -> void:
	if is_instance_valid(money_label):
		money_label.text = "Vpickup2  |  Money: $%d" % money
	if is_instance_valid(infinite_button):
		infinite_button.text = "Infinite: " + ("ON" if infinite_money else "OFF")

func _can_pay(amount: int) -> bool:
	return infinite_money or money >= amount

func _pay(amount: int) -> void:
	if not infinite_money:
		money -= amount
	_update_hud()
	_save_game()

func _do_work() -> void:
	money += 150
	status_label.text = "Work completed! You earned $150."
	_update_hud()
	_save_game()

func _toggle_infinite_money() -> void:
	infinite_money = not infinite_money
	status_label.text = "Infinite money " + ("enabled." if infinite_money else "disabled.")
	_update_hud()
	_save_game()

func _interact() -> void:
	match current_nearby_action:
		"dealer":
			if not _can_pay(CAR_PRICE):
				status_label.text = "Not enough money. Complete work to earn more."
				return
			_pay(CAR_PRICE)
			var old_vehicle := vehicle
			var new_vehicle: CharacterBody3D = VehicleScript.new()
			new_vehicle.name = "PurchasedPickup"
			new_vehicle.position = Vector3(42, 0.8, -36)
			add_child(new_vehicle)
			vehicle = new_vehicle
			_attach_camera(vehicle)
			if is_instance_valid(old_vehicle):
				old_vehicle.queue_free()
			current_nearby_action = ""
			status_label.text = "New pickup purchased! You are now driving it."
		"food":
			if _can_pay(FOOD_PRICE):
				_pay(FOOD_PRICE)
				status_label.text = "Food purchased. You spent $%d." % FOOD_PRICE
			else:
				status_label.text = "Not enough money. Complete work to earn more."
		_:
			if current_nearby_action.begins_with("house_"):
				var idx := int(current_nearby_action.trim_prefix("house_"))
				if owned_houses[idx]:
					status_label.text = "You already own this house."
				elif _can_pay(HOUSE_PRICE):
					_pay(HOUSE_PRICE)
					owned_houses[idx] = true
					status_label.text = "Congratulations! You bought house %d." % (idx + 1)
					_save_game()
				else:
					status_label.text = "Not enough money. Complete work to earn more."
			else:
				status_label.text = "Drive closer to a shop or a house to interact."

func _save_game() -> void:
	var save := ConfigFile.new()
	save.set_value("player", "money", money)
	save.set_value("player", "infinite_money", infinite_money)
	save.set_value("player", "owned_houses", owned_houses)
	if is_instance_valid(vehicle) and vehicle.is_inside_tree():
		save.set_value("player", "vehicle_position", vehicle.global_position)
		save.set_value("player", "vehicle_rotation", vehicle.global_rotation)
	save.save(SAVE_PATH)

func _load_game() -> void:
	var save := ConfigFile.new()
	if save.load(SAVE_PATH) != OK:
		return
	money = int(save.get_value("player", "money", money))
	infinite_money = bool(save.get_value("player", "infinite_money", infinite_money))
	var saved_position = save.get_value("player", "vehicle_position", saved_vehicle_position)
	var saved_rotation = save.get_value("player", "vehicle_rotation", saved_vehicle_rotation)
	if saved_position is Vector3:
		saved_vehicle_position = saved_position
	if saved_rotation is Vector3:
		saved_vehicle_rotation = saved_rotation
	var saved_houses = save.get_value("player", "owned_houses", owned_houses)
	if saved_houses is Array and saved_houses.size() == 6:
		owned_houses.assign(saved_houses)
