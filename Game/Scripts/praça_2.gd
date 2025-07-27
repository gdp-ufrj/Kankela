class_name praca_2 extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var geraldo: CharacterBody2D = %Geraldo
@onready var natalia: CharacterBody2D = %Natália
@onready var maga: CharacterBody2D = %Maga
var arquivo_dialogo: String = "res://Dialogues/praça_2.dialogue"
@export_file("*.tscn") var area: String

func _ready():
	player.last_walk_animation = "Walk_back"
	player.animacao.play("Idle_back")

	if Engine.has_singleton("DialogueManager"):
		player.start_cutscene(load(arquivo_dialogo), "prep")
		await DialogueManager.dialogue_ended

		player.visible = true
		SceneManager.play_audio("res://Assets/Audio/SFX/puf.ogg")
		await get_tree().create_timer(0.5).timeout

		player.start_cutscene(load(arquivo_dialogo), "start")
		await DialogueManager.dialogue_ended

		maga.visible = true
		SceneManager.play_audio("res://Assets/Audio/SFX/puf.ogg")
		await get_tree().create_timer(1).timeout

		player.start_cutscene(load(arquivo_dialogo), "maga_entrance")
		await DialogueManager.dialogue_ended

		player.visible = false
		maga.visible = false
		SceneManager.play_audio("res://Assets/Audio/SFX/puf.ogg")
		await get_tree().create_timer(2).timeout

		player.start_cutscene(load(arquivo_dialogo), "finale")
		await DialogueManager.dialogue_ended
		natalia.move_to_position(Vector2(264, 72), 10.0)
		geraldo.move_to_position(Vector2(264, 72), 10.3)

		await get_tree().create_timer(3).timeout
		player.change_scene_to(area)
