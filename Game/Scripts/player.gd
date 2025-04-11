extends CharacterBody2D


const SPEED = 300.0

@onready var animacao := $Anim as AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Movimento horizontal (eixo X)
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	
	# Combina as direções em um vetor e normaliza para movimento diagonal
	var direction := Vector2(direction_x, direction_y).normalized()
	
	if direction != Vector2.ZERO:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		
		# Animação de andar
		$Anim.play("Andando")
		
		# Vira o sprite horizontalmente conforme a direção
		if direction.x != 0:
			animacao.scale.x = direction.x
	else:
		# Desacelera suavemente até parar
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
		# Animação de idle (parado)
		$Anim.play("Parada")

	# Aplicando o movimento
	move_and_slide()
