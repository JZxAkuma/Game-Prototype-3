shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.1);
uniform sampler2D scroll_texture : repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
	  vec2 uv = UV + scroll_speed * TIME;

     COLOR = texture(scroll_texture, uv);
	
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
