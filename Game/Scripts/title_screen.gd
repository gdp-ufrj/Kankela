extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Surface.tscn")


func _on_settings_pressed() -> void:
	print("Configurações pressionado!")


func _on_quit_pressed() -> void:
	get_tree().quit()
