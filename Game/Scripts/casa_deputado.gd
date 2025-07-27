extends Node2D

@onready var player: CharacterBody2D = %Player
var arquivo_dialogo: String = "res://Dialogues/casa_deputado.dialogue"


func _ready():
	if Engine.has_singleton("DialogueManager"):
		player.can_use_lupa = true
		player.start_cutscene(load(arquivo_dialogo), "start")
		await DialogueManager.dialogue_ended
