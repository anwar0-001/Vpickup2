extends Node3D
## Vpickup2: original procedural driving/life-simulation prototype.

const VehicleScript = preload("res://scripts/pickup_vehicle.gd")
const TrafficCarScript = preload("res://scripts/traffic_car.gd")
const SAVE_PATH := "user://vpickup2_save.cfg"
const HOUSE_PRICE := 1200
const FOOD_PRICE := 25
const CAR_PRICE := 2500
const DELIVERY_REWARD := 350
const DELIVERY_PICKUP := Vector3(-24, 0.0, -15)
const DELIVERY_DROPOFF := Vector3(24, 0.0, -86)
const DAY_LENGTH_SECONDS := 480.0
const GAME_DAY_SECONDS := 86400.0

var money: int = 500
var infinite_money := true
var owned_houses: Array[bool] = [false, false, false, false, false, false]
var current_nearby_action := ""
var vehicle: CharacterBody3D
var saved_vehicle_position := Vector3(-24, 0.8, 4)
var saved_vehicle_rotation := Vector3.ZERO
var status_label: Label
var money_label: Label
var speed_label: Label
var action_button: Button
var pause_button: Button
var pause_menu: PanelContainer
var infinite_button: Button
var world_environment: WorldEnvironment
var sun_light: DirectionalLight3D
var sky_material: ProceduralSkyMaterial
var day_night_label: Label
var mission_label: Label
var street_lights: Array[OmniLight3D] = []
var game_time_seconds := 8.0 * 3600.0
var autosave_elapsed := 0.0
var touch_actions: Array[String] = ["steer_left", "steer_right", "accelerate", "brake"]
var mission_stage: int = 0 # 0 = available, 1 = collect parcel, 2 = deliver parcel
var pickup_marker: Node3D
var dropoff_marker: Node3D
var package_visual: MeshInstance3D

func _ready() -> void:
	_load_game()
	add_to_group("day_night_controller")
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
	sun_light = DirectionalLight3D.new()
	sun_light.name = "Sun"
	sun_light.rotation_degrees = Vector3(-48, -30, 0)
	sun_light.light_energy = 1.35
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_max_distance = 120.0
	add_child(sun_light)
	world_environment = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.fog_enabled = true
	env.fog_light_color = Color(0.58, 0.68, 0.76)
	env.fog_density = 0.0015
	env.fog_sun_scatter = 0.12
	env.sky = Sky.new()
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.10, 0.25, 0.48)
	sky_material.sky_horizon_color = Color(0.58, 0.75, 0.91)
	sky_material.ground_bottom_color = Color(0.16, 0.20, 0.16)
	sky_material.ground_horizon_color = Color(0.58, 0.68, 0.70)
	sky_material.sun_angle_max = 18.0
	env.sky.sky_material = sky_material
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.79, 0.9)
	env.ambient_light_energy = 0.85
	env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	env.tonemap_exposure = 1.05
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = env
	add_child(world_environment)

func _material(color: Color, roughness := 0.9, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
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
	# Painted centre dashes and road edges.
	for i in range(17):
		_box(self, "VillageRoadDash_%d" % i, Vector3(0.12, 0.025, 2.1), Vector3(-24, 0.0, -27.0 + float(i) * 6.0), Color(0.92, 0.83, 0.55), false)
		_box(self, "CityRoadDash_%d" % i, Vector3(0.12, 0.025, 2.1), Vector3(24, 0.04, -96.0 + float(i) * 5.0), Color(0.92, 0.83, 0.55), false)
	for side in [-1.0, 1.0]:
		_box(self, "VillageRoadEdge_%s" % str(side), Vector3(0.09, 0.025, 105), Vector3(-24 + side * 3.15, 0.005, 22), Color(0.78, 0.78, 0.70), false)
		_box(self, "CityRoadEdge_%s" % str(side), Vector3(0.09, 0.025, 90), Vector3(24 + side * 3.15, 0.06, -55), Color(0.78, 0.78, 0.70), false)
	_box(self, "ConnectingRoadDash", Vector3(40, 0.025, 0.12), Vector3(0, 0.02, -23), Color(0.92, 0.83, 0.55), false)
	# Low concrete curbs make the asphalt sit more naturally in the environment.
	for side in [-1.0, 1.0]:
		_box(self, "VillageCurb_%s" % str(side), Vector3(0.22, 0.16, 105), Vector3(-24 + side * 3.68, -0.035, 22), Color(0.47, 0.48, 0.45), false)
		_box(self, "CityCurb_%s" % str(side), Vector3(0.22, 0.16, 90), Vector3(24 + side * 3.68, -0.015, -55), Color(0.48, 0.49, 0.47), false)
	for side in [-1.0, 1.0]:
		_box(self, "ConnectingCurb_%s" % str(side), Vector3(55, 0.16, 0.22), Vector3(side * 0.0, -0.02, -23 + side * 3.68), Color(0.48, 0.49, 0.47), false)
	_label_3d("VILLAGE", Vector3(-40, 2, 62), Color(1, 0.94, 0.68))
	_label_3d("CITY", Vector3(35, 2, -82), Color(0.72, 0.9, 1))
	_create_village()
	_create_city()
	_create_shops()
	_create_street_furniture()
	_create_distant_landscape()
	_create_delivery_points()
	_create_traffic()
	_create_road_signs()
	_create_road_lane_markings()
	_create_bus_stops_and_benches()
	_create_pedestrian_crossing_signals()

func _create_road_signs() -> void:
	# Simple roadside speed-limit signs help distinguish village and city driving.
	var pole_material := _material(Color(0.20, 0.21, 0.22), 0.55, 0.35)
	var sign_back := _material(Color(0.91, 0.92, 0.88), 0.62, 0.0)
	var sign_red := _material(Color(0.78, 0.10, 0.08), 0.48, 0.0)
	for sign_data in [
		{"name": "VillageSpeedSign", "position": Vector3(-29.7, 0.0, -8.0), "limit": "30", "caption": "VILLAGE"},
		{"name": "CitySpeedSign", "position": Vector3(18.5, 0.0, -10.0), "limit": "40", "caption": "CITY"}
	]:
		var sign_position: Vector3 = sign_data["position"]
		_box(self, sign_data["name"] + "_Pole", Vector3(0.12, 2.35, 0.12), sign_position + Vector3(0, 1.18, 0), Color(0.24, 0.25, 0.26), false)
		_box(self, sign_data["name"] + "_Board", Vector3(0.92, 0.92, 0.12), sign_position + Vector3(0, 2.35, 0), sign_back.albedo_color, false)
		var border := _box(self, sign_data["name"] + "_RedBorder", Vector3(0.82, 0.82, 0.035), sign_position + Vector3(0, 2.35, -0.078), sign_red.albedo_color, false)
		var face := _box(self, sign_data["name"] + "_Face", Vector3(0.70, 0.70, 0.04), sign_position + Vector3(0, 2.35, -0.102), Color(0.94, 0.94, 0.88), false)
		var limit_label := Label3D.new()
		limit_label.name = sign_data["name"] + "_Limit"
		limit_label.text = str(sign_data["limit"])
		limit_label.font_size = 64
		limit_label.pixel_size = 0.012
		limit_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		limit_label.modulate = Color(0.12, 0.13, 0.14)
		limit_label.position = sign_position + Vector3(0, 2.35, -0.14)
		add_child(limit_label)
		var area_label := Label3D.new()
		area_label.name = sign_data["name"] + "_Area"
		area_label.text = str(sign_data["caption"])
		area_label.font_size = 22
		area_label.pixel_size = 0.01
		area_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		area_label.modulate = Color(1.0, 0.92, 0.62)
		area_label.position = sign_position + Vector3(0, 3.05, 0)
		add_child(area_label)

func _create_bus_stops_and_benches() -> void:
	# Small roadside props add scale and make the city sidewalks feel inhabited.
	var metal_material := _material(Color(0.18, 0.21, 0.23), 0.52, 0.48)
	var wood_material := _material(Color(0.42, 0.25, 0.13), 0.82, 0.0)
	var glass_material := _material(Color(0.35, 0.58, 0.67), 0.28, 0.0)
	var bin_material := _material(Color(0.24, 0.34, 0.29), 0.72, 0.1)
	for stop_index in range(2):
		var stop_z := -70.0 + float(stop_index) * 38.0
		var stop_x := 29.6 if stop_index == 0 else 18.4
		_box(self, "BusStop_%d_Base" % stop_index, Vector3(2.4, 0.12, 1.3), Vector3(stop_x, 0.19, stop_z), Color(0.48, 0.49, 0.46), false)
		for leg_index in range(4):
			var leg_x := -0.92 if leg_index % 2 == 0 else 0.92
			var leg_z := -0.42 if leg_index < 2 else 0.42
			_box(self, "BusStop_%d_Leg_%d" % [stop_index, leg_index], Vector3(0.09, 1.7, 0.09), Vector3(stop_x + leg_x, 1.02, stop_z + leg_z), metal_material.albedo_color, false)
		_box(self, "BusStop_%d_Roof" % stop_index, Vector3(2.6, 0.14, 1.55), Vector3(stop_x, 1.95, stop_z), Color(0.20, 0.34, 0.43), false)
		_box(self, "BusStop_%d_BackGlass" % stop_index, Vector3(2.25, 1.25, 0.055), Vector3(stop_x, 1.18, stop_z - 0.48), glass_material.albedo_color, false)
		_box(self, "BusStop_%d_BenchSeat" % stop_index, Vector3(1.65, 0.12, 0.42), Vector3(stop_x, 0.72, stop_z + 0.08), wood_material.albedo_color, false)
		_box(self, "BusStop_%d_BenchBack" % stop_index, Vector3(1.65, 0.48, 0.10), Vector3(stop_x, 1.0, stop_z + 0.27), wood_material.albedo_color, false)
		_box(self, "BusStop_%d_SignPole" % stop_index, Vector3(0.08, 2.1, 0.08), Vector3(stop_x + 1.55, 1.05, stop_z + 0.15), metal_material.albedo_color, false)
		_box(self, "BusStop_%d_SignBoard" % stop_index, Vector3(0.48, 0.62, 0.12), Vector3(stop_x + 1.55, 2.0, stop_z + 0.15), Color(0.12, 0.42, 0.32), false)
		_label_3d("BUS", Vector3(stop_x + 1.55, 2.0, stop_z + 0.06), Color(1.0, 0.96, 0.72))
	for bin_index in range(5):
		var bin_z := -90.0 + float(bin_index) * 17.0
		var bin_x := 19.0 if bin_index % 2 == 0 else 29.0
		_box(self, "StreetBin_%d_Body" % bin_index, Vector3(0.48, 0.78, 0.48), Vector3(bin_x, 0.48, bin_z), bin_material.albedo_color, false)
		_box(self, "StreetBin_%d_Lid" % bin_index, Vector3(0.54, 0.10, 0.54), Vector3(bin_x, 0.91, bin_z), metal_material.albedo_color, false)

func _create_pedestrian_crossing_signals() -> void:
	# Compact pedestrian signals at the city cross streets, built from primitive meshes.
	var pole_color := Color(0.16, 0.18, 0.19)
	var housing_color := Color(0.12, 0.13, 0.14)
	for crossing_index in range(5):
		var z := -78.0 + float(crossing_index) * 16.0
		for side in [-1.0, 1.0]:
			var x := 19.1 if side < 0.0 else 28.9
			var tag := "PedSignal_%d_%s" % [crossing_index, str(side)]
			_box(self, tag + "_Pole", Vector3(0.12, 2.15, 0.12), Vector3(x, 1.08, z - 2.3), pole_color, false)
			_box(self, tag + "_Head", Vector3(0.42, 0.62, 0.24), Vector3(x, 2.30, z - 2.3), housing_color, false)
			var red_lens := MeshInstance3D.new()
			red_lens.name = tag + "_Red"
			var red_mesh := SphereMesh.new()
			red_mesh.radius = 0.105
			red_mesh.height = 0.12
			red_lens.mesh = red_mesh
			red_lens.position = Vector3(x, 2.43, z - 2.16)
			red_lens.material_override = _material(Color(0.86, 0.12, 0.09), 0.25)
			add_child(red_lens)
			var green_lens := MeshInstance3D.new()
			green_lens.name = tag + "_Green"
			var green_mesh := SphereMesh.new()
			green_mesh.radius = 0.105
			green_mesh.height = 0.12
			green_lens.mesh = green_mesh
			green_lens.position = Vector3(x, 2.18, z - 2.16)
			green_lens.material_override = _material(Color(0.15, 0.72, 0.28), 0.25)
			add_child(green_lens)

func _create_road_lane_markings() -> void:
	# Dashed centre line on the city road; low-profile mesh strips avoid physics changes.
	for segment in range(18):
		var z := -99.0 + float(segment) * 4.8
		_box(self, "CityLaneDash_%02d" % segment, Vector3(0.10, 0.025, 2.25), Vector3(24.0, 0.055, z), Color(0.91, 0.87, 0.68), false)

func _create_traffic() -> void:
	# Two lanes of low-speed traffic make the city feel active without heavy AI.
	var traffic_specs := [
		[22.0, -92.0, 1.0, 6.0],
		[26.0, -66.0, -1.0, 5.2],
		[22.0, -38.0, 1.0, 6.8],
		[26.0, -15.0, -1.0, 5.6]
	]
	for i in range(traffic_specs.size()):
		var spec: Array = traffic_specs[i]
		var traffic_car: CharacterBody3D = TrafficCarScript.new()
		traffic_car.name = "CityTraffic_%d" % (i + 1)
		traffic_car.lane_x = float(spec[0])
		traffic_car.travel_min_z = -101.0
		traffic_car.travel_max_z = -9.0
		traffic_car.initial_direction = float(spec[2])
		traffic_car.travel_speed = float(spec[3])
		traffic_car.position = Vector3(float(spec[0]), 0.0, float(spec[1]))
		add_child(traffic_car)

func _create_village() -> void:
	for i in range(7):
		var x := -47.0 + float(i % 4) * 11.0
		var z := 18.0 + float(i / 4) * 15.0
		_building("VillageHouse_%d" % i, Vector3(6, 4, 6), Vector3(x, 1.3, z), Color(0.69, 0.48, 0.31), Color(0.37, 0.19, 0.12))
	for i in range(18):
		var x := -76.0 + float(i) * 8.5
		var z := 42.0 + float(i % 3) * 5.0
		_box(self, "TreeTrunk_%d" % i, Vector3(0.45, 3.2, 0.45), Vector3(x, 1.0, z), Color(0.30, 0.18, 0.09))
		var crown := MeshInstance3D.new()
		crown.name = "TreeCrown_%d" % i
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 1.8
		crown_mesh.height = 3.8
		crown.mesh = crown_mesh
		crown.position = Vector3(x, 3.6, z)
		var foliage_color := Color(0.12 + float(i % 3) * 0.025, 0.30 + float(i % 4) * 0.025, 0.11)
		crown.material_override = _material(foliage_color, 0.95)
		add_child(crown)
		# Three overlapping foliage clusters break up the single-sphere silhouette.
		var foliage_offsets := [Vector3(-1.0, -0.25, 0.35), Vector3(0.9, 0.05, 0.2), Vector3(0.0, 0.5, -0.85)]
		for cluster_index in range(foliage_offsets.size()):
			var cluster := MeshInstance3D.new()
			cluster.name = "TreeFoliage_%d_%d" % [i, cluster_index]
			var cluster_mesh := SphereMesh.new()
			cluster_mesh.radius = 1.18
			cluster_mesh.height = 2.55
			cluster.mesh = cluster_mesh
			cluster.position = Vector3(x, 3.6, z) + foliage_offsets[cluster_index]
			var shade := 0.94 + float((i + cluster_index) % 3) * 0.06
			cluster.material_override = _material(Color(foliage_color.r * shade, foliage_color.g * shade, foliage_color.b * shade), 0.98)
			add_child(cluster)

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


	# High-contrast pedestrian crossings at the city intersections.
	for crossing_index in range(5):
		var crossing_z := -78.0 + float(crossing_index) * 16.0
		for stripe in range(5):
			var stripe_x := 20.8 + float(stripe) * 1.6
			_box(self, "Crosswalk_%d_%d" % [crossing_index, stripe], Vector3(0.95, 0.035, 0.34), Vector3(stripe_x, 0.105, crossing_z), Color(0.88, 0.89, 0.84), false)
		# Small planted islands make the city streets feel less empty.
		for side in [-1.0, 1.0]:
			var planter_x := 16.5 if side < 0.0 else 31.5
			_box(self, "StreetPlanter_%d_%s" % [crossing_index, str(side)], Vector3(1.2, 0.35, 2.0), Vector3(planter_x, 0.18, crossing_z), Color(0.38, 0.31, 0.23), false)
			var shrub := MeshInstance3D.new()
			shrub.name = "StreetShrub_%d_%s" % [crossing_index, str(side)]
			var shrub_mesh := SphereMesh.new()
			shrub_mesh.radius = 0.62
			shrub_mesh.height = 0.9
			shrub.mesh = shrub_mesh
			shrub.position = Vector3(planter_x, 0.72, crossing_z)
			shrub.material_override = _material(Color(0.12, 0.32, 0.16), 0.95)
			add_child(shrub)

func _create_shops() -> void:
	_building("CarDealership", Vector3(13, 5, 10), Vector3(42, 2, -48), Color(0.20, 0.46, 0.68), Color(0.08, 0.15, 0.22))
	# Shop fascia panels and display glazing make the entrances read clearly from the road.
	_box(self, "DealershipSignPanel", Vector3(8.8, 0.72, 0.16), Vector3(42, 4.15, -42.82), Color(0.06, 0.12, 0.18), false)
	_box(self, "DealershipDisplayGlassL", Vector3(3.2, 1.75, 0.07), Vector3(39.0, 2.1, -42.84), Color(0.18, 0.40, 0.53), false)
	_box(self, "DealershipDisplayGlassR", Vector3(3.2, 1.75, 0.07), Vector3(45.0, 2.1, -42.84), Color(0.24, 0.48, 0.60), false)
	_label_3d("CAR DEALER\nE: Buy vehicle", Vector3(42, 4.12, -42.65), Color(0.85, 0.96, 1))
	_building("FoodMarket", Vector3(10, 4, 9), Vector3(7, 1.5, -48), Color(0.25, 0.58, 0.32), Color(0.12, 0.26, 0.13))
	_box(self, "FoodMarketSignPanel", Vector3(7.4, 0.68, 0.16), Vector3(7, 3.18, -43.30), Color(0.10, 0.25, 0.12), false)
	_box(self, "FoodMarketDisplayGlassL", Vector3(2.25, 1.35, 0.07), Vector3(4.6, 1.65, -43.34), Color(0.25, 0.48, 0.58), false)
	_box(self, "FoodMarketDisplayGlassR", Vector3(2.25, 1.35, 0.07), Vector3(9.4, 1.65, -43.34), Color(0.36, 0.58, 0.64), false)
	# Warm storefront lighting joins the existing day/night street-light controller.
	for shop_light_data in [
		{"name": "DealershipEntranceGlow", "position": Vector3(42, 3.0, -41.8), "color": Color(0.64, 0.82, 1.0)},
		{"name": "FoodMarketEntranceGlow", "position": Vector3(7, 2.6, -42.4), "color": Color(1.0, 0.72, 0.38)}
	]:
		var shop_light := OmniLight3D.new()
		shop_light.name = shop_light_data["name"]
		shop_light.position = shop_light_data["position"]
		shop_light.light_color = shop_light_data["color"]
		shop_light.light_energy = 0.0
		shop_light.omni_range = 8.0
		shop_light.shadow_enabled = false
		add_child(shop_light)
		street_lights.append(shop_light)
	_label_3d("FOOD MARKET\nE: Buy food", Vector3(7, 3.14, -43.12), Color(0.82, 1, 0.82))
	# Marked parking bays beside the dealership for a more believable town.
	_box(self, "DealershipParkingLot", Vector3(18, 0.10, 12), Vector3(42, 0.015, -34), Color(0.23, 0.24, 0.24), false)
	for bay in range(5):
		var bay_x := 35.0 + float(bay) * 3.5
		_box(self, "ParkingBayLine_%d" % bay, Vector3(0.07, 0.025, 4.8), Vector3(bay_x, 0.08, -34), Color(0.91, 0.91, 0.84), false)
	_box(self, "ParkingStopLine", Vector3(17, 0.025, 0.08), Vector3(42, 0.08, -31.5), Color(0.91, 0.91, 0.84), false)
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
	# A darker plinth and a narrow facade band add depth to otherwise box-built walls.
	_box(self, building_name + "_Foundation", Vector3(size.x + 0.08, 0.24, 0.10), pos + Vector3(0, -size.y / 2.0 + 0.18, size.z / 2.0 + 0.045), Color(0.38, 0.37, 0.33), false)
	if building_name == "CarDealership" or building_name == "FoodMarket":
		var awning_color := Color(0.13, 0.29, 0.42) if building_name == "CarDealership" else Color(0.78, 0.72, 0.43)
		_box(self, building_name + "_EntranceAwning", Vector3(size.x * 0.72, 0.14, 1.0), pos + Vector3(0, 0.35, size.z / 2.0 + 0.48), awning_color, false)
	if size.y > 4.5:
		var glass_colors := [Color(0.24,0.48,0.62), Color(0.62,0.72,0.76), Color(0.86,0.68,0.38)]
		for floor_index in range(maxi(1, int(size.y / 2.8))):
			for window_index in range(3):
				var wx := (float(window_index) - 1.0) * size.x * 0.27
				var wy := -size.y * 0.5 + 1.45 + float(floor_index) * 2.35
				if wy < size.y * 0.42:
					var glass_color: Color = glass_colors[(floor_index + window_index) % glass_colors.size()]
					_box(self, building_name + "_FrontWindow_%d_%d" % [floor_index, window_index], Vector3(maxf(0.65, size.x * 0.14), 0.85, 0.055), pos + Vector3(wx, wy, size.z / 2.0 + 0.09), glass_color, false)
		for side in [-1.0, 1.0]:
			for floor_index in range(maxi(1, int(size.y / 3.0))):
				for window_index in range(2):
					var wz := (float(window_index) - 0.5) * size.z * 0.38
					var wy := -size.y * 0.5 + 1.5 + float(floor_index) * 2.5
					if wy < size.y * 0.42:
						_box(self, building_name + "_SideWindow_%s_%d_%d" % [str(side), floor_index, window_index], Vector3(0.055, 0.8, 0.8), pos + Vector3(side * (size.x / 2.0 + 0.09), wy, wz), Color(0.25,0.46,0.59), false)

func _create_player() -> void:
	vehicle = VehicleScript.new()
	vehicle.name = "PlayerPickup"
	vehicle.position = saved_vehicle_position
	vehicle.rotation = saved_vehicle_rotation
	add_child(vehicle)
	_attach_camera(vehicle)
	if mission_stage == 2:
		_attach_delivery_package()

func _attach_camera(target_vehicle: Node3D) -> void:
	var camera := Camera3D.new()
	camera.name = "FollowCamera"
	camera.position = Vector3(0, 5.8, 9.5)
	camera.rotation_degrees = Vector3(-23, 0, 0)
	camera.fov = 75.0
	target_vehicle.add_child(camera)
	camera.current = true

func _create_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "GameUI"
	add_child(layer)
	var edition_label := Label.new()
	edition_label.name = "EditionTitle"
	edition_label.text = "VPICKUP2  |  الإصدار الثاني"
	edition_label.add_theme_font_size_override("font_size", 24)
	edition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	edition_label.anchor_left = 0.30
	edition_label.anchor_right = 0.70
	edition_label.offset_top = 18
	edition_label.offset_bottom = 52
	layer.add_child(edition_label)
	day_night_label = Label.new()
	day_night_label.name = "DayNightClock"
	day_night_label.add_theme_font_size_override("font_size", 20)
	day_night_label.anchor_left = 0.02
	day_night_label.anchor_right = 0.30
	day_night_label.offset_top = 126
	day_night_label.offset_bottom = 156
	layer.add_child(day_night_label)
	mission_label = Label.new()
	mission_label.name = "MissionObjective"
	mission_label.text = "MISSION  |  Start a delivery to earn $%d" % DELIVERY_REWARD
	mission_label.add_theme_font_size_override("font_size", 18)
	mission_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.48))
	mission_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_label.anchor_left = 0.24
	mission_label.anchor_right = 0.76
	mission_label.offset_top = 54
	mission_label.offset_bottom = 96
	layer.add_child(mission_label)
	speed_label = Label.new()
	speed_label.name = "Speedometer"
	speed_label.text = "0 km/h  |  N"
	speed_label.add_theme_font_size_override("font_size", 30)
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	speed_label.anchor_left = 1.0
	speed_label.anchor_right = 1.0
	speed_label.offset_left = -300
	speed_label.offset_right = -20
	speed_label.offset_top = 20
	speed_label.offset_bottom = 62
	layer.add_child(speed_label)
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
	status_label.text = "Drive to explore. Start a delivery, visit shops and houses."
	status_label.custom_minimum_size = Vector2(260, 45)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(status_label)
	var controls := HBoxContainer.new()
	vbox.add_child(controls)
	var earn_button := Button.new()
	earn_button.text = "Delivery +$%d" % DELIVERY_REWARD
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
	pause_button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "Ⅱ"
	pause_button.custom_minimum_size = Vector2(64, 52)
	pause_button.anchor_left = 1.0
	pause_button.anchor_right = 1.0
	pause_button.offset_left = -86
	pause_button.offset_right = -18
	pause_button.offset_top = 72
	pause_button.offset_bottom = 126
	pause_button.pressed.connect(_toggle_pause_menu)
	layer.add_child(pause_button)
	_create_pause_menu(layer)
	# On-screen controls are available on phones and tablets; keyboard remains supported.
	_make_hold_button(layer, "◀", "steer_left", Vector2(18, -142), Vector2(66, 62), false)
	_make_hold_button(layer, "▶", "steer_right", Vector2(92, -142), Vector2(66, 62), false)
	_make_hold_button(layer, "▲", "accelerate", Vector2(-166, -214), Vector2(68, 62), true)
	_make_hold_button(layer, "▼", "brake", Vector2(-92, -142), Vector2(68, 62), true)
	var help := Label.new()
	help.text = "WASD / arrows or touch controls"
	help.position = Vector2(18, 126)
	layer.add_child(help)

func _create_pause_menu(layer: CanvasLayer) -> void:
	pause_menu = PanelContainer.new()
	pause_menu.name = "PauseMenu"
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = false
	pause_menu.anchor_left = 0.5
	pause_menu.anchor_right = 0.5
	pause_menu.anchor_top = 0.5
	pause_menu.anchor_bottom = 0.5
	pause_menu.offset_left = -190
	pause_menu.offset_right = 190
	pause_menu.offset_top = -165
	pause_menu.offset_bottom = 165
	layer.add_child(pause_menu)
	var menu_items := VBoxContainer.new()
	menu_items.add_theme_constant_override("separation", 12)
	pause_menu.add_child(menu_items)
	var title := Label.new()
	title.text = "PAUSED  |  اللعبة متوقفة"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	menu_items.add_child(title)
	var resume_button := Button.new()
	resume_button.text = "متابعة اللعب"
	resume_button.custom_minimum_size.y = 52
	resume_button.pressed.connect(_resume_game)
	menu_items.add_child(resume_button)
	var save_button := Button.new()
	save_button.text = "حفظ التقدم الآن"
	save_button.custom_minimum_size.y = 52
	save_button.pressed.connect(_save_from_pause_menu)
	menu_items.add_child(save_button)
	var quit_button := Button.new()
	quit_button.text = "حفظ والخروج"
	quit_button.custom_minimum_size.y = 52
	quit_button.pressed.connect(_quit_game)
	menu_items.add_child(quit_button)

func _toggle_pause_menu() -> void:
	if not is_instance_valid(pause_menu):
		return
	if get_tree().paused:
		_resume_game()
	else:
		pause_menu.visible = true
		get_tree().paused = true

func _resume_game() -> void:
	get_tree().paused = false
	if is_instance_valid(pause_menu):
		pause_menu.visible = false

func _save_from_pause_menu() -> void:
	_save_game()
	if is_instance_valid(status_label):
		status_label.text = "تم حفظ التقدم بنجاح."

func _quit_game() -> void:
	_save_game()
	get_tree().paused = false
	get_tree().quit()

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

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause_menu()
	_update_day_night(delta)
	autosave_elapsed += delta
	if autosave_elapsed >= 10.0:
		autosave_elapsed = 0.0
		_save_game()
	if Input.is_action_just_pressed("interact"):
		_interact()
	if not is_instance_valid(vehicle):
		return
	if is_instance_valid(speed_label):
		var current_speed := float(vehicle.get("speed"))
		var vehicle_speed := absf(current_speed)
		var gear := "R" if current_speed < -0.5 else ("D" if current_speed > 0.5 else "N")
		speed_label.text = "%d km/h  |  %s" % [roundi(vehicle_speed * 3.6), gear]
	var p := vehicle.global_position
	_update_mission_objective(p)
	var dealer_distance := Vector2(p.x - 42, p.z + 48).length()
	var food_distance := Vector2(p.x - 7, p.z + 48).length()
	var pickup_distance := Vector2(p.x - DELIVERY_PICKUP.x, p.z - DELIVERY_PICKUP.z).length()
	var dropoff_distance := Vector2(p.x - DELIVERY_DROPOFF.x, p.z - DELIVERY_DROPOFF.z).length()
	current_nearby_action = ""
	if mission_stage == 1 and pickup_distance < 8.0:
		current_nearby_action = "mission_pickup"
		status_label.text = "Parcel pickup: stop nearby and press Interact."
	elif mission_stage == 2 and dropoff_distance < 8.0:
		current_nearby_action = "mission_dropoff"
		status_label.text = "Delivery destination: stop nearby and press Interact. Reward: $%d." % DELIVERY_REWARD
	elif dealer_distance < 10:
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

func _update_mission_objective(player_position: Vector3) -> void:
	if not is_instance_valid(mission_label):
		return
	var target_position := Vector3.ZERO
	var objective_text := ""
	match mission_stage:
		1:
			target_position = DELIVERY_PICKUP
			objective_text = "Collect parcel at village"
		2:
			target_position = DELIVERY_DROPOFF
			objective_text = "Drop parcel in city"
		_:
			mission_label.text = "MISSION  |  Start a delivery to earn $%d" % DELIVERY_REWARD
			return
	var target_offset := Vector2(target_position.x - player_position.x, target_position.z - player_position.z)
	var distance_to_target := target_offset.length()
	var forward_3d := -vehicle.global_transform.basis.z
	var forward := Vector2(forward_3d.x, forward_3d.z).normalized()
	var direction_to_target := target_offset.normalized()
	var relative_angle := forward.angle_to(direction_to_target)
	var direction_hint := "↑ AHEAD"
	if relative_angle > 0.38:
		direction_hint = "↻ RIGHT"
	elif relative_angle < -0.38:
		direction_hint = "↺ LEFT"
	if mission_stage == 1:
		mission_label.text = "DELIVERY  |  %s  |  %d m  |  %s" % [objective_text, roundi(distance_to_target), direction_hint]
	else:
		mission_label.text = "DELIVERY  |  %s  |  %d m  |  %s  |  Reward: $%d" % [objective_text, roundi(distance_to_target), direction_hint, DELIVERY_REWARD]

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
	if mission_stage != 0:
		status_label.text = "Finish your current delivery before starting another one."
		return
	mission_stage = 1
	status_label.text = "Delivery accepted! Collect the parcel at the yellow marker in the village."
	_update_delivery_markers()
	_save_game()

func _toggle_infinite_money() -> void:
	infinite_money = not infinite_money
	status_label.text = "Infinite money " + ("enabled." if infinite_money else "disabled.")
	_update_hud()
	_save_game()

func _interact() -> void:
	match current_nearby_action:
		"mission_pickup":
			if mission_stage != 1:
				return
			mission_stage = 2
			_attach_delivery_package()
			_update_delivery_markers()
			status_label.text = "Parcel collected! Deliver it to the blue marker in the city for $%d." % DELIVERY_REWARD
			_save_game()
		"mission_dropoff":
			if mission_stage != 2:
				return
			mission_stage = 0
			money += DELIVERY_REWARD
			if is_instance_valid(package_visual):
				package_visual.queue_free()
				package_visual = null
			_update_delivery_markers()
			_update_hud()
			status_label.text = "Delivery completed! You earned $%d." % DELIVERY_REWARD
			_save_game()
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
			if mission_stage == 2:
				if is_instance_valid(package_visual):
					package_visual.queue_free()
					package_visual = null
				_attach_delivery_package()
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
	save.set_value("missions", "delivery_stage", mission_stage)
	save.set_value("world", "time_seconds", game_time_seconds)
	if is_instance_valid(vehicle) and vehicle.is_inside_tree():
		save.set_value("player", "vehicle_position", vehicle.global_position)
		save.set_value("player", "vehicle_rotation", vehicle.global_rotation)
	save.save(SAVE_PATH)

func _load_game() -> void:
	var save := ConfigFile.new()
	if save.load(SAVE_PATH) != OK:
		return
	money = int(save.get_value("player", "money", money))
	mission_stage = clampi(int(save.get_value("missions", "delivery_stage", 0)), 0, 2)
	game_time_seconds = float(save.get_value("world", "time_seconds", game_time_seconds))
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

 
func _create_delivery_points() -> void:
	pickup_marker = _make_delivery_marker("ParcelPickupMarker", DELIVERY_PICKUP, Color(1.0, 0.72, 0.12), "PARCEL PICKUP")
	dropoff_marker = _make_delivery_marker("ParcelDropoffMarker", DELIVERY_DROPOFF, Color(0.18, 0.68, 1.0), "DELIVERY")
	_update_delivery_markers()

func _make_delivery_marker(marker_name: String, marker_position: Vector3, marker_color: Color, marker_text: String) -> Node3D:
	var marker := Node3D.new()
	marker.name = marker_name
	marker.position = marker_position
	add_child(marker)
	var beacon := MeshInstance3D.new()
	beacon.name = "Beacon"
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.32
	beacon_mesh.bottom_radius = 0.55
	beacon_mesh.height = 1.8
	beacon.mesh = beacon_mesh
	beacon.position = Vector3(0, 1.0, 0)
	var beacon_material := _material(marker_color, 0.25, 0.1)
	beacon_material.emission_enabled = true
	beacon_material.emission = marker_color
	beacon_material.emission_energy_multiplier = 1.3
	beacon.material_override = beacon_material
	marker.add_child(beacon)
	var ring := MeshInstance3D.new()
	ring.name = "GroundRing"
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 1.35
	ring_mesh.bottom_radius = 1.35
	ring_mesh.height = 0.06
	ring.mesh = ring_mesh
	ring.position.y = 0.08
	ring.material_override = _material(marker_color, 0.35, 0.0)
	marker.add_child(ring)
	var label := Label3D.new()
	label.name = "MarkerLabel"
	label.text = marker_text
	label.font_size = 32
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = marker_color
	label.position = Vector3(0, 2.4, 0)
	marker.add_child(label)
	return marker

func _update_delivery_markers() -> void:
	if is_instance_valid(pickup_marker):
		pickup_marker.visible = mission_stage != 2
	if is_instance_valid(dropoff_marker):
		dropoff_marker.visible = mission_stage == 2

func _attach_delivery_package() -> void:
	if not is_instance_valid(vehicle) or is_instance_valid(package_visual):
		return
	var package_mesh := BoxMesh.new()
	package_mesh.size = Vector3(0.72, 0.52, 0.62)
	package_visual = MeshInstance3D.new()
	package_visual.name = "DeliveryParcel"
	package_visual.mesh = package_mesh
	package_visual.position = Vector3(0, 1.42, 1.12)
	package_visual.material_override = _material(Color(0.68, 0.43, 0.20), 0.9)
	vehicle.add_child(package_visual)

func _update_day_night(delta: float) -> void:
	game_time_seconds = fposmod(game_time_seconds + delta * GAME_DAY_SECONDS / DAY_LENGTH_SECONDS, GAME_DAY_SECONDS)
	var hour := game_time_seconds / 3600.0
	var daylight := clampf(sin((hour - 6.0) * PI / 12.0), 0.0, 1.0)
	var darkness := 1.0 - daylight
	if is_instance_valid(sun_light):
		sun_light.rotation_degrees = Vector3(hour / 24.0 * 360.0 + 90.0, -30.0, 0.0)
		sun_light.light_energy = lerpf(0.035, 1.35, daylight)
		sun_light.light_color = Color(0.54, 0.66, 1.0).lerp(Color(1.0, 0.91, 0.76), daylight)
	if is_instance_valid(world_environment) and world_environment.environment != null:
		var env := world_environment.environment
		env.ambient_light_color = Color(0.10, 0.16, 0.32).lerp(Color(0.72, 0.79, 0.9), daylight)
		env.ambient_light_energy = lerpf(0.22, 0.85, daylight)
	if is_instance_valid(sky_material):
		sky_material.sky_top_color = Color(0.008, 0.015, 0.07).lerp(Color(0.10, 0.25, 0.48), daylight)
		sky_material.sky_horizon_color = Color(0.035, 0.055, 0.13).lerp(Color(0.58, 0.75, 0.91), daylight)
		sky_material.ground_bottom_color = Color(0.025, 0.035, 0.045).lerp(Color(0.16, 0.20, 0.16), daylight)
		sky_material.ground_horizon_color = Color(0.04, 0.07, 0.12).lerp(Color(0.58, 0.68, 0.70), daylight)
	for street_light in street_lights:
		if is_instance_valid(street_light):
			street_light.light_energy = 1.8 if darkness > 0.45 else 0.0
	if is_instance_valid(day_night_label):
		var hour_int := int(floor(hour))
		var minute_int := int(floor(fposmod(game_time_seconds, 3600.0) / 60.0))
		var period := "Night" if hour < 6.0 or hour >= 18.0 else ("Sunrise" if hour < 8.0 else ("Sunset" if hour >= 16.0 else "Day"))
		day_night_label.text = "Time %02d:%02d  |  %s" % [hour_int, minute_int, period]

func _create_street_furniture() -> void:
	var pole_mat := _material(Color(0.18, 0.20, 0.22), 0.55, 0.35)
	var curb_mat := _material(Color(0.56, 0.57, 0.54), 0.9)
	var lamp_mat := StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.82, 0.48)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.55, 0.20)
	lamp_mat.emission_energy_multiplier = 1.4
	_box(self, "CitySidewalkLeft", Vector3(1.2, 0.18, 90), Vector3(19.9, 0.08, -55), curb_mat, false)
	_box(self, "CitySidewalkRight", Vector3(1.2, 0.18, 90), Vector3(28.1, 0.08, -55), curb_mat, false)
	_box(self, "VillageSidewalkLeft", Vector3(0.65, 0.14, 82), Vector3(-28.0, 0.04, 22), curb_mat, false)
	_box(self, "VillageSidewalkRight", Vector3(0.65, 0.14, 82), Vector3(-20.0, 0.04, 22), curb_mat, false)
	# Subtle expansion joints give sidewalks scale and help them read as separate concrete slabs.
	var joint_mat := _material(Color(0.34, 0.36, 0.35), 1.0)
	for slab in range(20):
		var seam_z := -98.0 + float(slab) * 4.5
		_box(self, "CitySidewalkJointL_%d" % slab, Vector3(1.12, 0.018, 0.035), Vector3(19.9, 0.18, seam_z), joint_mat, false)
		_box(self, "CitySidewalkJointR_%d" % slab, Vector3(1.12, 0.018, 0.035), Vector3(28.1, 0.18, seam_z), joint_mat, false)
	for slab in range(18):
		var seam_z := -17.0 + float(slab) * 4.5
		_box(self, "VillageSidewalkJointL_%d" % slab, Vector3(0.60, 0.018, 0.035), Vector3(-28.0, 0.12, seam_z), joint_mat, false)
		_box(self, "VillageSidewalkJointR_%d" % slab, Vector3(0.60, 0.018, 0.035), Vector3(-20.0, 0.12, seam_z), joint_mat, false)
	# Small metal drainage grates beside city intersections.
	var grate_mat := _material(Color(0.12, 0.14, 0.15), 0.72, 0.45)
	for crossing_index in range(5):
		var grate_z := -78.0 + float(crossing_index) * 16.0
		for side in [-1.0, 1.0]:
			var grate_x := 20.25 if side < 0.0 else 27.75
			_box(self, "RoadDrain_%d_%s" % [crossing_index, str(side)], Vector3(0.32, 0.025, 0.72), Vector3(grate_x, 0.105, grate_z + 2.1), grate_mat, false)
			for bar in range(5):
				_box(self, "RoadDrainBar_%d_%s_%d" % [crossing_index, str(side), bar], Vector3(0.30, 0.028, 0.035), Vector3(grate_x, 0.122, grate_z + 1.82 + float(bar) * 0.14), curb_mat, false)
	for i in range(9):
		var z := -91.0 + float(i) * 9.0
		var x := 18.7 if i % 2 == 0 else 29.3
		_box(self, "StreetLightPole_%d" % i, Vector3(0.16, 5.8, 0.16), Vector3(x, 2.9, z), pole_mat, false)
		_box(self, "StreetLightArm_%d" % i, Vector3(1.25, 0.12, 0.14), Vector3(x + (0.45 if x < 24.0 else -0.45), 5.65, z), pole_mat, false)
		var lamp_x := x + (0.95 if x < 24.0 else -0.95)
		_box(self, "StreetLight_%d" % i, Vector3(0.52, 0.12, 0.36), Vector3(lamp_x, 5.55, z), lamp_mat, false)
		var street_light := OmniLight3D.new()
		street_light.name = "StreetLightGlow_%d" % i
		street_light.position = Vector3(lamp_x, 5.2, z)
		street_light.light_color = Color(1.0, 0.68, 0.36)
		street_light.light_energy = 0.0
		street_light.omni_range = 16.0
		street_light.shadow_enabled = false
		add_child(street_light)
		street_lights.append(street_light)
	for i in range(8):
		var z := -14.0 + float(i) * 10.0
		var x := -30.8 if i % 2 == 0 else -17.2
		_box(self, "VillageFencePost_%d" % i, Vector3(0.16, 0.9, 0.16), Vector3(x, 0.45, z), pole_mat, false)
		_box(self, "VillageFenceRail_%d" % i, Vector3(0.12, 0.12, 4.8), Vector3(x, 0.65, z + 2.4), curb_mat, false)

func _create_distant_landscape() -> void:
	var hill_colors := [Color(0.29,0.40,0.31), Color(0.35,0.46,0.34), Color(0.40,0.48,0.40)]
	for i in range(11):
		var hill := MeshInstance3D.new()
		hill.name = "DistantHill_%d" % i
		var hill_mesh := SphereMesh.new()
		hill_mesh.radius = 1.0
		hill_mesh.height = 2.0
		hill_mesh.radial_segments = 12
		hill_mesh.rings = 6
		hill.mesh = hill_mesh
		var scale_x := 16.0 + float(i % 3) * 5.0
		var scale_y := 8.0 + float(i % 4) * 2.5
		hill.scale = Vector3(scale_x, scale_y, 11.0)
		hill.position = Vector3(-105.0 + float(i) * 21.0, scale_y - 1.0, -112.0 - float(i % 3) * 5.0)
		hill.material_override = _material(hill_colors[i % hill_colors.size()], 1.0)
		add_child(hill)
