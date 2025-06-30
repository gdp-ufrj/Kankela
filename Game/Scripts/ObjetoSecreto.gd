extends Sprite2D

# Enumeração para os tipos de lupa (deve ser igual ao da Lupa.gd)
enum LupaType {
	DESLIGADA = 0,
	TIPO_1 = 1,
	TIPO_2 = 2
}

var is_lupa_active: bool = false
var current_lupa_type: LupaType = LupaType.DESLIGADA

# Tipo de lupa necessário para revelar este objeto
@export var required_lupa_type: LupaType = LupaType.TIPO_1

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://Shaders/objeto_secreto.gdshader")
	
	# Adiciona este objeto ao grupo para que o player possa encontrá-lo
	add_to_group("objeto_secreto")

func _on_player_activate_lupa(esta_ativa: bool):
	is_lupa_active = esta_ativa
	update_reveal_state()

func _on_lupa_type_changed(lupa_type: LupaType):
	current_lupa_type = lupa_type
	update_reveal_state()

func update_reveal_state():
	var should_reveal = is_lupa_active and (current_lupa_type == required_lupa_type)
	material.set_shader_parameter("reveal_active", 1.0 if should_reveal else 0.0)

func _process(_delta: float) -> void:
	var local_mouse_pos = get_global_mouse_position()
	material.set_shader_parameter("screen_mask_center", local_mouse_pos)
