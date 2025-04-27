extends Control

@onready var player = get_node("../../")

func _on_continue_pressed() -> void:
	player.PauseMenu()


func _on_settings_pressed() -> void:
	print("Configurações pressionado!")


func _on_main_menu_pressed() -> void:
	player.PauseMenu()
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
