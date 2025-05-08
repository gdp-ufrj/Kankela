extends Node

@onready var game_root = $GameViewportContainer/GameViewport/GameRoot

@export_file("*.tscn") var title_screen: String

func _ready():
	SceneManager.setup(game_root)
	SceneManager.load_game_scene(title_screen)
