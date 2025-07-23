class_name praca extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var geraldo: CharacterBody2D = %Geraldo
@onready var natalia: CharacterBody2D = %Natália
@onready var maga: CharacterBody2D = %Maga
@export_file("*.dialogue") var arquivo_dialogo: String
@export_file("*.tscn") var area: String

func _ready():
	maga.visible = false
	player.animacao.play("Idle_back")

	if Engine.has_singleton("DialogueManager"):
		# Mostrar card com data 24/07/2017
		player.start_cutscene(load(arquivo_dialogo), "start")
		await DialogueManager.dialogue_ended

		maga.visible = true
		geraldo.move_to_position(Vector2(-24, 72))
		natalia.move_to_position(Vector2(24, 72))

		player.start_cutscene(load(arquivo_dialogo), "maga_entrance")
		await DialogueManager.dialogue_ended

		maga.visible = false
		SceneManager.load_game_scene(area)
