shader_type canvas_item;

// Uniforms
uniform vec2 local_mask_center;
uniform float mask_radius = 100.0;
uniform float edge_softness = 0.05;
uniform float reveal_active; // <-- NOSSO NOVO INTERRUPTOR (recebe 0.0 ou 1.0)

// Varying
varying vec2 local_vertex_pos;

void vertex() {
	local_vertex_pos = VERTEX;
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	float distance = distance(local_vertex_pos, local_mask_center);

	// Calcula a transparência da máscara circular (como antes)
	float mask_alpha = 1.0 - smoothstep(mask_radius - (mask_radius * edge_softness), mask_radius, distance);
	
	// --- NOVA PARTE ---
	// A transparência final é a da máscara MULTIPLICADA pelo nosso interruptor.
	// Se reveal_active for 0, o resultado final sempre será 0.
	// Se reveal_active for 1, o resultado será o valor da máscara.
	float final_alpha = mask_alpha * reveal_active;

	// Aplicamos a transparência final.
	COLOR = vec4(original_color.rgb, original_color.a * final_alpha);
}