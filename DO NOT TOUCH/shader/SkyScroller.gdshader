shader_type sky;

//Takes in the custom sky as an img
uniform sampler2D sky_texture;

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
    vec2 uv = SKY_COORDS;

    uv.x += TIME * 0.002;

    COLOR = texture(sky_texture, uv).rgb;
}
