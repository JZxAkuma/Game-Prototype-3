
shader_type spatial;
render_mode blend_mix,shadows_disabled;

uniform sampler2D water_texture : source_color;
uniform sampler2D emission_texture : source_color;

uniform vec2 tiling = vec2(1.0, 1.0);
uniform float scroll_speed = 0.05;
uniform float emission_strength : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec2 uv = UV * tiling;
    uv.x += TIME * scroll_speed;

    // Water texture
    vec4 tex = texture(water_texture, uv);

    ALBEDO = tex.rgb;
    ALPHA = tex.a;

    // Emission map
    vec3 emission = texture(emission_texture, uv).rgb;
    EMISSION = emission * emission_strength;
}