class_name Documento extends "res://Scripts/ObjetoInterativo.gd"

var hasInteracted: bool = false

# Dados para o player poder interagir
@onready var player = %Player

@onready var documento: Sprite2D = $Documento if has_node("Sprite2D") else null
@onready var segredos: Node2D = $Segredos
@onready var button_pressed: bool = false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# som ao colotar o item
@export var som_coletar: AudioStream

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"

# Sprite do Objeto
@export var sprite_objeto: Texture2D # Imagem do objeto no cenário
@export var sprite_documento: Texture2D # Imagem que será mostrada na tela
@export var clue_scale: Vector2 = Vector2(1, 1)

# Área de colisão do objeto:
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO


func _enter_tree() -> void: # Acontece antes do _ready()
	add_to_group("clues")


func _ready() -> void:
	# Ativando o sprite do objeto e das evidências
	sprite_texture = sprite_objeto
	if sprite_documento: documento.texture = sprite_documento
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao
	$AudioStreamPlayer.stream = som_coletar

	super._ready() # Força esse nó rodar a função _ready() do script que ele está estendendo


func interact(_player: Node) -> void:
	# request_interaction.emit(_player)
	# Define uma variável para indicar se o player está analisando a pista ou não
	player.interacting = not player.interacting
	hasInteracted = not hasInteracted

	documento.visible = player.interacting
	segredos.visible = player.interacting
	player.get_node("IconeInteracao").visible = not player.interacting
	player.get_node("AreaInteracao").monitoring = not player.get_node("AreaInteracao").monitoring

	# Se o player estiver analisando a pista
	if player.interacting:
		documento.global_position = player.global_position
		segredos.global_position = player.global_position
		documento.scale = clue_scale
		self.desativar_delineado()

		#Efeito audio
		if $AudioStreamPlayer.stream != null:
			$AudioStreamPlayer.play()

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
	if player.interacting:
		# Se o player pressiona "Espaço" enquanto analisa a pista, para de analisar ela
		if event.is_action_pressed("ui_select") and not event.is_echo():
			interact(player)
			# await get_tree().create_timer(0.2).timeout
