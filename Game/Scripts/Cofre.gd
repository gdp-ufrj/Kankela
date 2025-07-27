@tool
class_name Cofre extends "res://Scripts/ObjetoInterativo.gd"

var isInteracting: bool = false
var canInteract: bool = true

# Dados para o player poder interagir
@onready var player = %Player

#@onready var keypad: Sprite2D = $Keypad if has_node("Sprite2D") else null
@onready var keypad = $Keypad
@onready var keypad_label = $Keypad/VBoxContainer/MarginContainer/Label
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

var quest_manager = Engine.get_singleton("QuestManager")


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
	if canInteract:
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
			if keypad_label.text == "ACEITO":
				if Engine.has_singleton("QuestManager"):
					quest_manager.coletar_item("deputado_completed")
					player.start_cutscene_from_string("Valdiléia: Beleza, consegui os documentos. Agora só preciso ir embora daqui...")

					canInteract = false
	else:
		player.start_cutscene_from_string("Valdiléia: Eu já peguei o que eu queria, so preciso ir embora.")

	# Exibe mensagem no console
	print(texto_interacao)


func _input(event):
	if player.interacting and isInteracting:
		# Se o player pressiona "Espaço" enquanto analisa a pista, para de analisar ela
		if event.is_action_pressed("ui_select") and not event.is_echo():
			interact(player)
			await get_tree().create_timer(0.05).timeout
