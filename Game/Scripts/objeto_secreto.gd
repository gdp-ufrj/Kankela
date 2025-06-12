extends Sprite2D

var is_lupa_active: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("lupa"):
		is_lupa_active = not is_lupa_active

	var local_mouse_pos = to_local(get_global_mouse_position())
	material.set_shader_parameter("local_mask_center", local_mouse_pos)
	material.set_shader_parameter("reveal_active", is_lupa_active)
