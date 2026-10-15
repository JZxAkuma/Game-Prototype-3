shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture,
    repeat_disable, filter_nearest;
	
uniform float color_steps : hint_range(8.0, 64.0) = 32.0;
uniform float grain_strength : hint_range(0.0, 0.05) = 0.008;
uniform float saturation : hint_range(0.5, 1.5) = 1.05;
uniform float contrast : hint_range(0.8, 1.3) = 1.05;

void vertex() {
	// Called for every vertex the material is visible on.
}
void fragment() {
	// Called for every pixel the material is visible on.
    vec3 color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;//Contrast contrl
    color = (color - vec3(0.5)) * contrast + vec3(0.5);//saturation control
    float grey = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(grey), color, saturation);
	
	//grain
    float grain = fract(
        sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233)))
        * 43758.5453
    ) - 0.5;
    color += grain * grain_strength;

    //color quanting again
    color = floor(clamp(color, 0.0, 1.0) * color_steps + 0.5)
        / color_steps;
    COLOR = vec4(color, 1.0);
}
