class_name Porta extends "res://Scripts/ObjetoInterativo.gd"


@onready var player : CharacterBody2D = %Player
@export var area : String = "."
# Sprite da porta
@export var sprite_porta: Texture2D	# Exporta a textura da imagem

# Área de colisão da porta:
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Ativando o sprite da porta
	sprite_texture = sprite_porta
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao
	super._ready()	# Força esse nó rodar a função _ready() do script que ele está estendendo
	
	'''
	# Definindo a área de colisão da porta
	if collision_shape and forma_colisao:
		collision_shape.shape = forma_colisao
		collision_shape.position = posicao_colisao
'''

func interact(_player: Node) -> void:
	self.desativar_delineado()
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Door)
	
	# Muda de cena para o novo cenário
	get_tree().change_scene_to_file("res://Scenes/" + area + ".tscn")
