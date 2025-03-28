extends CharacterBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:
	# Movimento horizontal (eixo X)
	var direction_x := Input.get_axis("ui_left", "ui_right")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	# faz um leve efeito de derrapar até parar
		
	# Movimento vertical (eixo Y)
	var direction_y := Input.get_axis("ui_up", "ui_down")
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)	# faz um leve efeito de derrapar até parar

	# Aplicando o movimento
	move_and_slide()
