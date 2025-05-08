extends Control

@onready var player = get_node("../../")
@export_file("*.tscn") var title_screen: String

func _on_continue_pressed() -> void:
	player.PauseMenu()


func _on_settings_pressed() -> void:
	print("Configurações pressionado!")


func _on_main_menu_pressed() -> void:
	player.PauseMenu()
	SceneManager.load_game_scene(title_screen)
