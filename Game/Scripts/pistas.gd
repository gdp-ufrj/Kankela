class_name Clues extends "res://Scripts/ObjetoInterativo.gd"

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"
var hasInteracted: bool = false

# som ao colotar o item
@export var som_coletar: AudioStream

# Sprite do Objeto
@onready var clue: Sprite2D =  $SpriteClue
@onready var button_pressed: bool = false
@export var sprite_objeto: Texture2D		# Imagem do objeto no cenário
@export var clue_sprite: Texture2D		# Imagem que será mostrada na tela
@export var true_clue_sprite: Texture2D	# Verdadeira evidência que será mostrada na tela
@export var clue_scale: Vector2 = Vector2(1,1)

# Área de colisão do objeto:
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO

# Dados para o player poder interagir
# signal request_interaction(player)
@onready var player = %Player


func _enter_tree() -> void:		# Acontece antes do _ready()
	add_to_group("clues")


func _ready() -> void:
	# Ativando o sprite do objeto e das evidências
	sprite_texture = sprite_objeto
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao
	$AudioStreamPlayer.stream = som_coletar
	clue.texture = clue_sprite
	
	super._ready() # Força esse nó rodar a função _ready() do script que ele está estendendo
		

func interact(_player: Node) -> void:
	# request_interaction.emit(_player)
	
	# Define uma variável para indicar se o player está analisando a pista ou não
	player.interacting = not player.interacting
	hasInteracted = not hasInteracted
	
	clue.visible = player.interacting
	player.get_node("IconeInteracao").visible = not player.interacting
	player.get_node("AreaInteracao").monitoring = not player.get_node("AreaInteracao").monitoring
	
	# Se o player estiver analisando a pista
	if player.interacting:
		player.get
		clue.global_position = player.global_position
		clue.scale = clue_scale
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
		# Se o player ativar a lupa enquanto analisa a pista, mostra os segredos
		if event.is_action_pressed("lupa") and not event.is_echo():
			show_true_evidence()
		
		# Se o player pressiona "Espaço" enquanto analisa a pista, para de analisar ela
		elif event.is_action_pressed("ui_select") and not event.is_echo():
			interact(player)
			# await get_tree().create_timer(0.2).timeout


func show_true_evidence():
	button_pressed = not button_pressed
	if button_pressed:
		clue.texture = true_clue_sprite
	else:
		clue.texture = clue_sprite
