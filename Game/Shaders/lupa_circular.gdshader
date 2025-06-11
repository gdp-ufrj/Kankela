shader_type canvas_item;

// Parâmetros configuráveis
uniform float radius : hint_range(0.0, 0.5) = 0.45;
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.1) = 0.02;
uniform bool show_border = true;

// Parâmetros específicos para diferentes tipos de lupa
uniform bool uv_mode = false;
uniform vec4 uv_tint : source_color = vec4(0.8, 0.4, 1.0, 0.3);

void fragment() {
    // Obtém a cor original da textura
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calcula a distância do centro
    float dist_from_center = distance(UV, vec2(0.5));
    
    // Cria a máscara circular principal
    float circle_mask = 1.0 - smoothstep(radius - smoothness, radius + smoothness, dist_from_center);
    
    // Cria a borda se habilitada
    float border_mask = 1.0;
    if (show_border) {
        float outer_radius = radius;
        float inner_radius = radius - border_width;
        border_mask = smoothstep(inner_radius - smoothness, inner_radius + smoothness, dist_from_center) - 
                     smoothstep(outer_radius - smoothness, outer_radius + smoothness, dist_from_center);
    }
    
    // Aplica a máscara circular à cor
    vec4 final_color = tex_color;
    final_color.a *= circle_mask;
    
    // Adiciona efeito específico para modo UV
    if (uv_mode && circle_mask > 0.0) {
        final_color.rgb = mix(final_color.rgb, uv_tint.rgb, uv_tint.a);
    }
    
    // Adiciona a borda
    if (show_border && border_mask > 0.0) {
        final_color.rgb = mix(final_color.rgb, border_color.rgb, border_mask * border_color.a);
        final_color.a = max(final_color.a, border_mask * border_color.a);
    }
    
    COLOR = final_color;
}
