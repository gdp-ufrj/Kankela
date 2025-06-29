extends Control

@export var mask_radius: float = 100.0 # Sincronizado com objeto_secreto
@onready var circulo_ref = $Referencia

var is_lupa_active: bool = false

func _ready():
	visible = is_lupa_active

	# Aplica o material do shader
	if not circulo_ref.material:
		circulo_ref.material = ShaderMaterial.new()
		circulo_ref.material.shader = load("res://Shaders/lupa_circular.gdshader")

	# Altera o tamanho para o selecionado e corrige centralidade
	var rect_size = mask_radius * 2.0
	circulo_ref.size = Vector2(rect_size, rect_size)
	circulo_ref.position = Vector2(-rect_size / 2, -rect_size / 2)

func _on_player_activate_lupa(esta_ativa: bool):
	is_lupa_active = esta_ativa
	visible = is_lupa_active

# Exemplo de uso seguindo o mouse
func _process(_delta: float) -> void:
	var local_mouse_pos = get_global_mouse_position()
	global_position = local_mouse_pos
