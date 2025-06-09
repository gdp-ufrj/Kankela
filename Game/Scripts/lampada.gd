class_name Lampada extends "res://Scripts/ObjetoInterativo.gd"


@onready var player: CharacterBody2D = %Player
@export var sprite_lampada: Texture2D # Exporta a textura da imagem

# Sistema necessário para ligar as luzes
@onready var luz_ligada: bool = false
signal interagida(index: int)
@export_range(0,2) var lampada_index: int

func _ready() -> void:
	# Ativando o sprite da porta
	sprite_texture = sprite_lampada
	
	

func interact(_player: Node) -> void:
	if QuestManager.todas_missoes["ligar_lampadas"].is_em_andamento():
		luz_ligada = !luz_ligada
	
	interagida.emit(lampada_index)
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Lamp)
