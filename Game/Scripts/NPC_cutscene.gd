extends CharacterBody2D

var target_position: Vector2
var cutscene_tween: Tween

func move_to_position(target_pos: Vector2) -> void:
	if cutscene_tween:
		cutscene_tween.kill()
	
	cutscene_tween = create_tween()
	# Move o player usando Tween
	cutscene_tween.tween_property(self, "position", target_pos, 0.3)
	await cutscene_tween.finished