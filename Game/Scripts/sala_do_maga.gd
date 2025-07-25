extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var geraldo: CharacterBody2D = %Geraldo
@onready var natalia: CharacterBody2D = %Natália
@onready var maga: CharacterBody2D = %Maga
var arquivo_dialogo: String = "res://Dialogues/sala_do_maga.dialogue"
@export_file("*.tscn") var area: String

func _ready():
	player.animacao.play("Idle_back")

	if Engine.has_singleton("DialogueManager"):
		# Mostrar card com data 24/07/2017
		player.start_cutscene(load(arquivo_dialogo), "start", Vector2(0, 48))
		await DialogueManager.dialogue_ended

		await player.move_player_to_position(Vector2(-32, 48))
		await player.move_player_to_position(Vector2(-32, 8))
		await player.move_player_to_position(Vector2(0, 8))
		player.animacao.play("Idle_back")

		player.start_cutscene(load(arquivo_dialogo), "conversa")
		await DialogueManager.dialogue_ended

		player.visible = false

		player.start_cutscene(load(arquivo_dialogo), "finale", Vector2(0, 0), area)
		await DialogueManager.dialogue_ended
