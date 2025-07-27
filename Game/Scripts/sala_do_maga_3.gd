extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var maga: CharacterBody2D = %Maga
@onready var black: ColorRect = $Black

var arquivo_dialogo: String = "res://Dialogues/sala_do_maga_3.dialogue"
@export_file("*.tscn") var area: String

func _ready():
	black.modulate.a = 0.0
	black.visible = true

	if Engine.has_singleton("DialogueManager"):
		await player.move_player_to_position(Vector2(0, 48))
		await player.move_player_to_position(Vector2(-32, 48))
		await player.move_player_to_position(Vector2(-32, 8))
		await player.move_player_to_position(Vector2(0, 8))
		player.last_walk_animation = "Walk_back"
		player.animacao.play("Idle_back")

		player.start_cutscene(load(arquivo_dialogo), "start")
		await DialogueManager.dialogue_ended
		await get_tree().create_timer(1).timeout

		# Fade in do transparente para preto
		var tween_in = create_tween()
		tween_in.tween_property(black, "modulate:a", 1.0, 0) # 1 segundo de fade in
		await tween_in.finished
		# Maga estala os dedos
		SceneManager.play_audio("res://Assets/Audio/SFX/estalar.ogg")
		await get_tree().create_timer(2).timeout

		player.start_cutscene(load(arquivo_dialogo), "revelation")
		await DialogueManager.dialogue_ended

		# Fade do preto para transparente
		var tween_out = create_tween()
		tween_out.tween_property(black, "modulate:a", 0.0, 3.0) # 1 segundo de fade out
		await tween_out.finished
		
		player.start_cutscene(load(arquivo_dialogo), "finale")
		await DialogueManager.dialogue_ended
		await get_tree().create_timer(2).timeout

		player.start_cutscene(load(arquivo_dialogo), "finale2")
		await DialogueManager.dialogue_ended

		# Fade in do transparente para preto
		var tween_final = create_tween()
		tween_final.tween_property(black, "modulate:a", 1.0, 0) # 1 segundo de fade in
		await tween_final.finished
		# Maga estala os dedos
		SceneManager.play_audio("res://Assets/Audio/SFX/estalar_epico.ogg")
		await get_tree().create_timer(5).timeout
		
		player.change_scene_to("res://Scenes/title_screen.tscn")
