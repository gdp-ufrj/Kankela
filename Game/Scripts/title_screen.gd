extends Control

@export_file("*.tscn") var primeira_fase: String

func _on_play_pressed() -> void:
	# Reseta o estado do jogo antes de iniciar
	if Engine.has_singleton("QuestManager"):
		var quest_manager = Engine.get_singleton("QuestManager")
		quest_manager.recarregar_sistema()
	
	SceneManager.load_game_scene(primeira_fase)


func _on_settings_pressed() -> void:
	get_node("Configuracoes").show()

func _on_credits_pressed() -> void:
	get_node("Créditos").show()


func _on_quit_pressed() -> void:
	get_tree().quit()
