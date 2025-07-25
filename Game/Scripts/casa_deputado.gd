extends Node2D

@onready var player: CharacterBody2D = %Player
var arquivo_dialogo: String = "res://Dialogues/TROCAR PELO QUE PRECISAR.dialogue"


func _ready():
	if Engine.has_singleton("DialogueManager"):
		# Mostrar card com data 24/07/2017
		player.start_cutscene(load(arquivo_dialogo), "start")
		await DialogueManager.dialogue_ended
