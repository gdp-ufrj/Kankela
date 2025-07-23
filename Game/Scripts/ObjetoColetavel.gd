@tool
class_name ObjetoColetavel extends "res://Scripts/ObjetoInterativo.gd"

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"
var hasInteracted: bool = false

# som ao colotar o item
@export var som_coletar: AudioStream

# Área de colisão do objeto:
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var forma_colisao: Shape2D
@export var posicao_colisao: Vector2 = Vector2.ZERO

# Propriedades do item para o sistema de inventário
@export var item_id: String = "" # ID único do item (usado no QuestManager)
@export var item_nome: String = "" # Nome do item
@export var item_descricao: String = "" # Descrição do item

var quest_manager = Engine.get_singleton("QuestManager")

func _ready() -> void:
	CollisionShape = collision_shape
	FormaColisao = forma_colisao
	PosicaoColisao = posicao_colisao
	$AudioStreamPlayer.stream = som_coletar
	
	super._ready() # Força esse nó rodar a função _ready() do script que ele está estendendo
	
	# Registrar o item no sistema se ainda não estiver registrado
	if Engine.has_singleton("QuestManager") and item_id != "":
		# Registrar no QuestManager
		quest_manager.adicionar_item_sistema(
			item_id,
			item_nome if item_nome != "" else str(name),
			item_descricao,
			sprite_texture
		)
		
		# Verificar se o item já foi coletado anteriormente
		if quest_manager.todos_itens.has(item_id) and quest_manager.todos_itens[item_id].coletado:
			queue_free() # Remove o item do mundo se já foi coletado

func interact(_player: Node) -> void:
	if hasInteracted: return

	hasInteracted = true
	self.desativar_delineado()
	
	# Exibe mensagem no console
	print(texto_interacao)
	
	# Adiciona ao inventário, se QuestManager estiver disponível
	if Engine.has_singleton("QuestManager") and item_id != "":
		quest_manager.coletar_item(item_id)
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Item)
	
	#Efeito audio
	if $AudioStreamPlayer.stream != null:
		$AudioStreamPlayer.play()
	
	# Efeito visual de coleta (pode adicionar partículas ou animação)
	
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.5)
	self.interaction_finished.disconnect(_player._on_objeto_interaction_finished)
	tween.tween_callback(self.queue_free)
