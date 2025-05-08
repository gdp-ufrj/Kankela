extends Node

# Caminho direto ao GameRoot
@onready var game_root = $GameViewportContainer/GameViewport/GameRoot
@export_file("*.tscn") var cena_de_start: String

func _ready():
	load_game_scene(cena_de_start)

func load_game_scene(path: String) -> void:
	# Remove cena atual (se houver)
	for child in game_root.get_children():
		child.queue_free()

	# Carrega e instancia nova cena
	var scene = load(path)
	var instance = scene.instantiate()
	game_root.add_child(instance)
