class_name praca extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var geraldo: CharacterBody2D = %Geraldo
@onready var natalia: CharacterBody2D = %Natália
@onready var maga: CharacterBody2D = %Maga
var arquivo_dialogo: String = "res://Dialogues/praça.dialogue"
@export_file("*.tscn") var area: String

func _ready():
	maga.visible = false
	player.last_walk_animation = "Walk_back"
	player.animacao.play("Idle_back")

	if Engine.has_singleton("DialogueManager"):
		# Mostrar card com data 24/07/2017
		player.start_cutscene(load(arquivo_dialogo), "start")
		await DialogueManager.dialogue_ended

		maga.visible = true
		SceneManager.play_audio("")
		geraldo.move_to_position(Vector2(-24, 72), 300)
		natalia.move_to_position(Vector2(24, 72), 300)

		player.start_cutscene(load(arquivo_dialogo), "maga_entrance")
		await DialogueManager.dialogue_ended

		maga.visible = false
		player.visible = false

		player.start_cutscene(load(arquivo_dialogo), "finale")
		player.change_scene_to(area)
