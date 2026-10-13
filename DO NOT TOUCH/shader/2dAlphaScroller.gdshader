shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D scroll_texture : source_color;
uniform vec2 scroll_speed = vec2(0.05, 0.05);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = fract(UV + scroll_speed * TIME);
    vec4 tex_color = texture(scroll_texture, uv);

    COLOR = tex_color * tint;
    COLOR.a *= opacity;
}
