shader_type spatial;

uniform sampler2D normal_frame_1 : hint_normal;
uniform sampler2D normal_frame_2 : hint_normal;

uniform float frames_per_second : hint_range(1.0, 30.0, 1.0) = 8.0;
uniform float texture_scale : hint_range(0.1, 20.0, 0.1) = 2.0;
uniform float normal_strength : hint_range(0.0, 3.0, 0.05) = 1.0;

varying vec3 local_position;
varying vec3 local_normal;

uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color;
uniform bool use_albedo_texture = false;

void vertex() {
    local_position = VERTEX;
    local_normal = NORMAL;
}

void fragment() {
	vec3 final_albedo = albedo_color.rgb;

if (use_albedo_texture) {
    vec2 uv = UV;
    vec3 texture_color = texture(albedo_texture, uv).rgb;
    final_albedo *= texture_color;
}

ALBEDO = final_albedo;

    vec3 p = local_position * texture_scale;

    
    vec3 blend = pow(abs(normalize(local_normal)), vec3(4.0));
    blend /= max(blend.x + blend.y + blend.z, 0.0001);

    
    vec3 n1_x = texture(normal_frame_1, p.zy).rgb * 2.0 - 1.0;
    vec3 n1_y = texture(normal_frame_1, p.xz).rgb * 2.0 - 1.0;
    vec3 n1_z = texture(normal_frame_1, p.xy).rgb * 2.0 - 1.0;

    vec3 n2_x = texture(normal_frame_2, p.zy).rgb * 2.0 - 1.0;
    vec3 n2_y = texture(normal_frame_2, p.xz).rgb * 2.0 - 1.0;
    vec3 n2_z = texture(normal_frame_2, p.xy).rgb * 2.0 - 1.0;

    // Blend the three projections for each frame.
    vec3 frame_1 = normalize(
        n1_x * blend.x +
        n1_y * blend.y +
        n1_z * blend.z
    );

    vec3 frame_2 = normalize(
        n2_x * blend.x +
        n2_y * blend.y +
        n2_z * blend.z
    );

    // Switch frames at a fixed frame rate.
    float frame = mod(floor(TIME * frames_per_second), 2.0);

    vec3 painted_normal = mix(frame_1, frame_2, frame);


    painted_normal.xy *= normal_strength;
    painted_normal = normalize(painted_normal);

    NORMAL_MAP = painted_normal;
    NORMAL_MAP_DEPTH = 1.0;
}
