extends Node
## Applies lightweight procedural surface variation to the generated world.
## Shader uses the Compatibility renderer and avoids external texture downloads.

var _applied := false
var _rain_wetness := false
var _road_materials: Array[ShaderMaterial] = []

const SURFACE_SHADER := """
shader_type spatial;
render_mode world_vertex_coords, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.22, 0.23, 0.23, 1.0);
uniform float grain_scale = 2.0;
uniform float variation = 0.12;
uniform float surface_roughness : hint_range(0.0, 1.0) = 0.92;

float hash_cell(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float value_noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 local = fract(p);
    local = local * local * (3.0 - 2.0 * local);
    float a = hash_cell(cell);
    float b = hash_cell(cell + vec2(1.0, 0.0));
    float c = hash_cell(cell + vec2(0.0, 1.0));
    float d = hash_cell(cell + vec2(1.0, 1.0));
    return mix(mix(a, b, local.x), mix(c, d, local.x), local.y);
}

void fragment() {
    vec2 world_xz = VERTEX.xz;
    // Layer broad natural colour drift with finer grain instead of visible square noise.
    float broad = value_noise(world_xz * grain_scale * 0.16);
    float medium = value_noise(world_xz * grain_scale * 1.4);
    float fine = hash_cell(floor(world_xz * grain_scale * 11.0));
    float micro = value_noise(world_xz * grain_scale * 24.0);
    float shade = 1.0
        + (broad - 0.5) * variation
        + (medium - 0.5) * variation * 0.50
        + (fine - 0.5) * variation * 0.18
        + (micro - 0.5) * variation * 0.08;
    ALBEDO = clamp(base_color.rgb * shade, vec3(0.0), vec3(1.0));
    ROUGHNESS = clamp(surface_roughness + (fine - 0.5) * 0.035, 0.0, 1.0);
}
"""

func _process(_delta: float) -> void:
    if _applied:
        return
    var scene := get_tree().current_scene
    if scene == null:
        return
    var found := _apply_to_tree(scene)
    if found:
        _applied = true
        set_process(false)

func _apply_to_tree(parent: Node) -> bool:
    var found := false
    for child in parent.get_children():
        if child is MeshInstance3D:
            var mesh_instance := child as MeshInstance3D
            var surface_kind := _kind_for_name(mesh_instance.name)
            if not surface_kind.is_empty():
                mesh_instance.material_override = _make_material(surface_kind)
                found = true
        if _apply_to_tree(child):
            found = true
    return found

func _kind_for_name(node_name: String) -> String:
    if node_name == "Terrain":
        return "grass"
    if node_name in ["VillageRoad", "CityRoad", "ConnectingRoad"] or node_name.begins_with("CityCrossStreet_"):
        return "asphalt"
    return ""

func _make_material(kind: String) -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = SURFACE_SHADER
    var material := ShaderMaterial.new()
    material.shader = shader
    if kind == "grass":
        material.set_shader_parameter("base_color", Color(0.25, 0.43, 0.19, 1.0))
        material.set_shader_parameter("grain_scale", 0.82)
        material.set_shader_parameter("variation", 0.30)
        material.set_shader_parameter("surface_roughness", 1.0)
    else:
        material.set_shader_parameter("base_color", Color(0.13, 0.145, 0.155, 1.0) if _rain_wetness else Color(0.19, 0.20, 0.205, 1.0))
        material.set_shader_parameter("grain_scale", 3.2)
        material.set_shader_parameter("variation", 0.17)
        material.set_shader_parameter("surface_roughness", 0.46 if _rain_wetness else 0.96)
        _road_materials.append(material)
    return material

func set_rain_wetness(enabled: bool) -> void:
    _rain_wetness = enabled
    for road_material in _road_materials:
        if is_instance_valid(road_material):
            road_material.set_shader_parameter("base_color", Color(0.13, 0.145, 0.155, 1.0) if enabled else Color(0.19, 0.20, 0.205, 1.0))
            road_material.set_shader_parameter("surface_roughness", 0.46 if enabled else 0.96)
