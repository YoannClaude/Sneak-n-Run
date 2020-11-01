shader_type canvas_item;

uniform vec2 target = vec2(0.5);
uniform float force: hint_range(0f, 0.5f);
uniform float size;
uniform float thickness;

void fragment()
{
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) -  vec2(0.5, 0.0);
	float mask = (1.0 - smoothstep(size - 0.01, size, length(scaledUV - target))) *
			smoothstep(size - thickness - 0.01, size - thickness , length(scaledUV - target));
	vec2 disp = normalize(scaledUV - target) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	//COLOR.rgb = vec3(mask);
}