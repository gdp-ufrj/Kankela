class_name ObjetoColetavel extends "res://Scripts/ObjetoInterativo.gd"

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"
var hasInteracted: bool = false

# Sprite do Objeto
@export var sprite_objeto : Texture2D

# Área de colisão do objeto:
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Ativando o sprite do objeto
	sprite_texture = sprite_objeto
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao
	super._ready()	# Força esse nó rodar a função _ready() do script que ele está estendendo

func interact(_player: Node) -> void:
	if hasInteracted: return

	hasInteracted = true
	self.desativar_delineado()
	# Exibe mensagem no console
	print(texto_interacao)
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Item)
	
	# Efeito visual de coleta (pode adicionar partículas ou animação)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.5)
	self.interaction_finished.disconnect(_player._on_objeto_interaction_finished)
	tween.tween_callback(self.queue_free)
