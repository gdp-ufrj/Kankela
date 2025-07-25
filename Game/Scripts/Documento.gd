@tool
class_name Documento extends "res://Scripts/ObjetoInterativo.gd"

var isInteracting: bool = false

# Dados para o player poder interagir
@onready var player = %Player

@onready var documento: Sprite2D = $Documento if has_node("Sprite2D") else null
@onready var segredos: Node2D = $Segredos
@onready var blur: ColorRect = $Blur
@onready var button_pressed: bool = false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"

# Sprite do Objeto
@export var sprite_objeto: Texture2D # Imagem do objeto no cenário
@export var sprite_documento: Texture2D # Imagem que será mostrada na tela

# Área de colisão do objeto:
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO

# Configuração dos objetos secretos
@export_group("Objetos Secretos")
@export var objetos_secretos_sprites: Array[Texture2D] = []
@export var objetos_secretos_tipos_lupa: Array[int] = [] # 0=DESLIGADA, 1=TIPO_1, 2=TIPO_2
@export var objetos_secretos_posicoes: Array[Vector2] = []
@export var objetos_secretos_escalas: Array[Vector2] = []


func _enter_tree() -> void: # Acontece antes do _ready()
	add_to_group("clues")


func _ready() -> void:
	# Ativando o sprite do objeto e das evidências
	sprite_texture = sprite_objeto
	if sprite_documento: documento.texture = sprite_documento
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao

	# Instanciar objetos secretos configurados
	_criar_objetos_secretos()

	super._ready() # Força esse nó rodar a função _ready() do script que ele está estendendo


func _criar_objetos_secretos() -> void:
	var count = objetos_secretos_sprites.size()
	
	for i in count:
		var objeto_sprite = objetos_secretos_sprites[i] if i < objetos_secretos_sprites.size() else null
		var lupa_type = objetos_secretos_tipos_lupa[i] if i < objetos_secretos_tipos_lupa.size() else 0
		var objeto_position = objetos_secretos_posicoes[i] if i < objetos_secretos_posicoes.size() else Vector2.ZERO
		var objeto_scale = objetos_secretos_escalas[i] if i < objetos_secretos_escalas.size() else Vector2(1, 1)
		
		if objeto_sprite == null:
			continue
			
		var objeto_secreto_script = preload("res://Scripts/ObjetoSecreto.gd")
		var objeto_secreto = Sprite2D.new()
		objeto_secreto.set_script(objeto_secreto_script)
		
		# Configurar as propriedades básicas
		objeto_secreto.texture = objeto_sprite
		objeto_secreto.position = objeto_position
		objeto_secreto.scale = objeto_scale
		
		# Adicionar como filho do node Segredos primeiro
		segredos.add_child(objeto_secreto)
		
		# Configurar o required_lupa_type após adicionar à árvore
		objeto_secreto.required_lupa_type = lupa_type


func interact(_player: Node) -> void:
	# request_interaction.emit(_player)
	# Define uma variável para indicar se o player está analisando a pista ou não
	player.interacting = not player.interacting
	isInteracting = not isInteracting

	documento.visible = player.interacting
	blur.visible = player.interacting
	segredos.visible = player.interacting
	player.get_node("IconeInteracao").visible = not player.interacting
	player.get_node("AreaInteracao").monitoring = not player.get_node("AreaInteracao").monitoring

	# Se o player estiver analisando a pista
	if player.interacting:
		documento.global_position = player.global_position
		segredos.global_position = player.global_position
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
