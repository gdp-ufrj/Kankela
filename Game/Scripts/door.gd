@tool
class_name Porta extends "res://Scripts/ObjetoInterativo.gd"

@onready var player: CharacterBody2D = %Player
@export_file("*.tscn") var area: String

var can_interact: bool = true
var interaction_debounce: float = 0.05

# Área de colisão da porta:
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO

# Sistema de itens necessários para abrir a porta
@export var porta_destrancada: bool = true
@export var item_necessario: String = "" # ID do item necessário (como uma chave)
@export var consumir_item: bool = false # Se verdadeiro, o item será usado (removido do inventário)
@export var mensagem_proibido_passar: String = "Você ainda não pode passar por aqui"

# Se a porta foi destrancada permanentemente

#transicao de cenario
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var transition: CanvasLayer = get_node("/root/TransicaoLayer")

func _ready() -> void:
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao
	super._ready() # Força esse nó rodar a função _ready() do script que ele está estendendo
	
	'''
	# Definindo a área de colisão da porta
	if collision_shape and forma_colisao:
		collision_shape.shape = forma_colisao
		collision_shape.position = posicao_colisao
	'''

func interact(_player: Node) -> void:
	if not can_interact:
		return

	can_interact = false

	# Verificar se a porta precisa de um item e se o sistema está disponível
	if porta_destrancada:
		#inicia a transição
		transition.fade_out()
		await transition.fade_out()
		await get_tree().create_timer(0.5).timeout # Pequeno delay
		audio_player.play()
		await audio_player.finished
		await get_tree().create_timer(0.5).timeout
		
		SceneManager.load_game_scene(area)
		
		#faz o fade_in após o carregamento
		transition.fade_in()

	else:
		if item_necessario != "" and Engine.has_singleton("QuestManager"):
			if QuestManager.tem_item_disponivel(item_necessario):
				# Gasta o item se ativado
				if consumir_item:
					QuestManager.usar_item(item_necessario)
				porta_destrancada = true
				# Muda de cena para o novo cenário
				SceneManager.load_game_scene(area)
			else:
				if Engine.has_singleton("DialogueManager"):
						_player.start_cutscene_from_string(mensagem_proibido_passar)
				else:
					# Caso o Dialogue Manager não esteja disponível, exibe mensagem padrão
					print("Sistema de diálogo não disponível.")
	
	await DialogueManager.dialogue_ended
	get_tree().create_timer(interaction_debounce).timeout.connect(func(): can_interact = true)
	desativar_delineado()
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Door)
