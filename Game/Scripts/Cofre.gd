@tool
class_name Cofre extends "res://Scripts/ObjetoInterativo.gd"

var isInteracting: bool = false

# Dados para o player poder interagir
@onready var player = %Player

@onready var keypad: Sprite2D = $Keypad if has_node("Sprite2D") else null
@onready var black: ColorRect = $Black
@onready var button_pressed: bool = false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"

# Sprite do Objeto
@export var sprite_objeto: Texture2D # Imagem do objeto no cenário

# Área de colisão do objeto:
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Ativando o sprite do objeto e das evidências
	sprite_texture = sprite_objeto
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao

	super._ready() # Força esse nó rodar a função _ready() do script que ele está estendendo

func interact(_player: Node) -> void:
	# request_interaction.emit(_player)
	# Define uma variável para indicar se o player está analisando a pista ou não
	player.interacting = not player.interacting
	isInteracting = not isInteracting

	keypad.visible = player.interacting
	black.visible = player.interacting

	player.get_node("IconeInteracao").visible = not player.interacting
	player.get_node("AreaInteracao").monitoring = not player.get_node("AreaInteracao").monitoring

	# Se o player estiver analisando a pista
	if player.interacting:
		keypad.global_position = player.global_position
		self.desativar_delineado()

	else:
		# Emite o sinal de interação
		interaction_finished.emit(InteractableType.Clues)

	# Exibe mensagem no console
	print(texto_interacao)

	# Animação da pista crescendo na tela
	'''
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.5)'''


func _input(event):
	if player.interacting and isInteracting:
		# Se o player pressiona "Espaço" enquanto analisa a pista, para de analisar ela
		if event.is_action_pressed("ui_select") and not event.is_echo():
			interact(player)
			# await get_tree().create_timer(0.2).timeout
