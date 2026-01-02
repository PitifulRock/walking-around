shader_type spatial;
render_mode unshaded;

uniform vec4 albedo: source_color;
uniform sampler2D noise_displace;
uniform float noise_strength : hint_range(0.0, 10.0, 0.01);
uniform float water_speed : hint_range(0.0, 4.0);

uniform sampler2D foam_texture : filter_nearest;
uniform float foam_speed : hint_range(-1.0, 2.0);

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;

uniform vec3 edge_color : source_color;
uniform float edge_distance : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform sampler2D edge_distort_texture;
uniform float edge_distort_amt : hint_range(0.0, 2.0);
uniform float edge_speed : hint_range(-1.0, 2.0);

void vertex() {
	float height = texture(noise_displace, UV + TIME * water_speed).r;
	VERTEX.y += height*noise_strength;
}

void fragment() {
	vec3 main_color = mix(albedo.rgb, texture(foam_texture, UV+TIME*foam_speed).rgb, texture(foam_texture, UV+TIME*foam_speed).a);
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_text_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float diff = vertex_y - depth_text_y;
	
	//vec3 edge_tex = screen - depth_text_y * depth_blend;
	
	vec4 edge_noise = texture(edge_distort_texture, UV+TIME*edge_speed);
	vec4 edge_tex = edge_noise;
	
	float dist_diff = diff + ((edge_noise.r * 2.0) - 1.0) * edge_distort_amt;
	
	ALBEDO = mix(main_color, edge_color, step(dist_diff, edge_distance));
}