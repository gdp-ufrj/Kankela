shader_type canvas_item;

// Parâmetros configuráveis
uniform float edge_softness : hint_range(0.0, 0.1) = 0;
uniform float border_thickness : hint_range(0.0, 0.2) = 0.01;

void fragment() {
    // Obtém a cor original da textura
    vec4 tex_color = texture(TEXTURE, UV);

    // Calcula distância do centro (0.5, 0.5 é o centro)
    float dist_from_center = distance(UV, vec2(0.5));
    
    // O raio é sempre 0.5 (metade da largura/altura da textura)
    // Isso garante que o círculo sempre toque as bordas do TextureRect
    float radius = 0.5;
    
    // Cria a máscara da circunferência (borda)
    float outer_radius = radius;
    float inner_radius = radius - border_thickness;
    
    float outer_mask = 1.0 - smoothstep(outer_radius - edge_softness, outer_radius + edge_softness, dist_from_center);
    float inner_mask = 1.0 - smoothstep(inner_radius - edge_softness, inner_radius + edge_softness, dist_from_center);
    
    // A circunferência é a diferença entre o círculo externo e interno
    float circle_mask = outer_mask - inner_mask;

    // Aplica a máscara circular à transparência
    tex_color.a *= circle_mask;

    COLOR = tex_color;
}
