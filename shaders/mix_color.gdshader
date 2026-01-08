shader_type canvas_item;

uniform bool visible = true;
uniform sampler2D albedo_texture;
uniform vec4 albedo_color : source_color = vec4(1,1,1,1);

void fragment() {
	if (visible) {
		vec4 base_tex = texture(albedo_texture, UV);

		vec3 fin_tex = 1.0 - (1.0-base_tex.rgb)/max(albedo_color.rgb, vec3(0.0001));
		fin_tex = clamp(fin_tex, 0.0, 1.0);

		COLOR.rgb = fin_tex.rgb;
		COLOR.a = base_tex.a;
	}
	else {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
}
