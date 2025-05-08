extends Node

# Caminho direto ao GameRoot
var game_root: Node2D = null

func setup(root: Node2D) -> void:
	game_root = root

func load_game_scene(path: String) -> void:
	if game_root == null:
		push_error("GameRoot não configurado!")
		return

	if game_root.get_child_count() > 0:
		for child in game_root.get_children():
			child.queue_free()

	# Carrega e instancia nova cena
	var scene = load(path)
	var instance = scene.instantiate()
	game_root.add_child(instance)
