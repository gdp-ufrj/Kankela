extends CharacterBody2D

var target_position: Vector2
var cutscene_tween: Tween

func move_to_position(target_pos: Vector2, movement_speed: float = 50.0) -> void:
	if cutscene_tween:
		cutscene_tween.kill()
	
	cutscene_tween = create_tween()

	# Calcula o tempo baseado na distância e velocidade
	var distance = global_position.distance_to(target_position)
	var duration = distance / movement_speed

	# Move o player usando Tween
	cutscene_tween.tween_property(self, "position", target_pos, duration)
	await cutscene_tween.finished