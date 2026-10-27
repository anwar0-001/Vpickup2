extends Node
## Applies lightweight procedural surface variation to the generated world.
## Shader uses the Compatibility renderer and avoids external texture downloads.

var _applied := false

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

void fragment() {
    vec2 world_xz = VERTEX.xz;
    float broad = hash_cell(floor(world_xz * grain_scale));
    float fine = hash_cell(floor(world_xz * grain_scale * 7.0));
    float shade = 1.0 + (broad - 0.5) * variation + (fine - 0.5) * variation * 0.34;
    ALBEDO = clamp(base_color.rgb * shade, vec3(0.0), vec3(1.0));
    ROUGHNESS = surface_roughness;
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
        material.set_shader_parameter("base_color", Color(0.19, 0.20, 0.205, 1.0))
        material.set_shader_parameter("grain_scale", 3.2)
        material.set_shader_parameter("variation", 0.17)
        material.set_shader_parameter("surface_roughness", 0.96)
    return material
