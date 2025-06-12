# Lupa.gd
extends Sprite2D

var is_lupa_active: bool = false

func _ready():
	self.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("lupa"):
		is_lupa_active = not is_lupa_active
		self.visible = is_lupa_active

	if not is_lupa_active: return

	self.global_position = get_global_mouse_position()
