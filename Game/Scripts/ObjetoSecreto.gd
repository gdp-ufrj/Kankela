extends Sprite2D

var is_lupa_active: bool = false

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://Shaders/objeto_secreto.gdshader")

func _on_player_activate_lupa(esta_ativa: bool):
	is_lupa_active = esta_ativa
	print("sou objeto secreto e recebi o sinal")

func _process(_delta):
	var local_mouse_pos = to_local(get_global_mouse_position())
	material.set_shader_parameter("local_mask_center", local_mouse_pos)
	material.set_shader_parameter("reveal_active", is_lupa_active)
