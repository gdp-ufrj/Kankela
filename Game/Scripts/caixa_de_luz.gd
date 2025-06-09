class_name Caixa_luz extends "res://Scripts/ObjetoInterativo.gd"


@onready var player: CharacterBody2D = %Player
@export var sprite_caixa: Texture2D # Exporta a textura da imagem


# Sistema de itens necessários para ligar a caixa de luz
@export var item_necessario: String # ID do item necessário (No caso, o fusivel)
@export var consumir_fusivel: bool = false # Se verdadeiro, o item será usado (removido do inventário)
@export var mensagem_proibido_usar: String = "Você ainda não pode ligar a lâmpada" 

func _ready() -> void:
	# Ativando o sprite da porta
	sprite_texture = sprite_caixa
	
	

func interact(_player: Node) -> void:
	if QuestManager.todas_missoes["coletar_fusiveis"].is_em_andamento():
		# Verificar se a lâmpada pode ser acendida
		if item_necessario != "" and Engine.has_singleton("QuestManager"):
			if QuestManager.tem_item_disponivel(item_necessario):
				# Gasta o item se ativado
				if consumir_fusivel:
					QuestManager.usar_item(item_necessario)
					QuestManager.completar_missao("coletar_fusiveis")
					self.sprite.texture = load("res://Assets/Visuals/Sprites/exemplos/boxItem.png")
				
			else:
				if Engine.has_singleton("DialogueManager"):
						_player.start_cutscene(load("res://Dialogues/door.dialogue"))
				else:
					# Caso o Dialogue Manager não esteja disponível, exibe mensagem padrão
					print("Sistema de diálogo não disponível.")
		
		self.desativar_delineado()
		
		# Emite o sinal de interação
		interaction_finished.emit(InteractableType.Lamp)
