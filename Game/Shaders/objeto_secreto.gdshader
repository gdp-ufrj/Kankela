shader_type canvas_item;

// Uniforms
uniform vec2 screen_mask_center; // Mudança: coordenadas da tela
uniform float mask_radius = 100.0; // Agora em pixels da tela
uniform float edge_softness = 0;
uniform float reveal_active; // 0.0 = não revelado, 1.0 = revelado

// Varying
varying vec2 screen_vertex_pos; // Mudança: coordenadas da tela

void vertex() {
    // Converte as coordenadas locais para coordenadas globais da tela
    screen_vertex_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    // Agora usa coordenadas da tela para calcular a distância
    float distance = distance(screen_vertex_pos, screen_mask_center);

    // Calcula a transparência da máscara circular
    float mask_alpha = 1.0 - smoothstep(mask_radius - (mask_radius * edge_softness), mask_radius, distance);

    // A transparência final é a da máscara MULTIPLICADA pelo interruptor
    float final_alpha = mask_alpha * reveal_active;

    // Aplicamos a transparência final
    COLOR = vec4(original_color.rgb, original_color.a * final_alpha);
}