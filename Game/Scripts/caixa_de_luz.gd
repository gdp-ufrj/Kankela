@tool
class_name Caixa_luz extends "res://Scripts/ObjetoInterativo.gd"

var can_interact: bool = true
var interaction_debounce: float = 0.05

# Sistema de itens necessários para ligar a caixa de luz
@export var item_necessario: String # ID do item necessário (No caso, o fusivel)
@export var consumir_fusivel: bool = false # Se verdadeiro, o item será usado (removido do inventário)

func _ready() -> void:
	super._ready()
	
func interact(_player: Node) -> void:
	if not can_interact:
		return

	can_interact = false
	desativar_delineado()
	_player.get_node("IconeInteracao").visible = false

	if QuestManager.todas_missoes["coletar_fusiveis"].is_em_andamento():
		# Verificar se a lâmpada pode ser acendida
		if item_necessario != "" and Engine.has_singleton("QuestManager"):
			if QuestManager.tem_item_disponivel(item_necessario):
				# Gasta o item se ativado
				if consumir_fusivel:
					QuestManager.usar_item(item_necessario)
					QuestManager.completar_missao("coletar_fusiveis")
					_player.start_cutscene_from_string("Consegui! Agora só preciso acender as luzes.")
				
			else:
				if Engine.has_singleton("DialogueManager"):
						_player.start_cutscene_from_string("O quadro elétrico está quebrado. Parece faltar um fusível...")
						
						await DialogueManager.dialogue_ended
						get_tree().create_timer(interaction_debounce).timeout.connect(func(): can_interact = true)
						ativar_delineado()
						_player.get_node("IconeInteracao").visible = true
				else:
					# Caso o Dialogue Manager não esteja disponível, exibe mensagem padrão
					print("Sistema de diálogo não disponível.")
		
		# Emite o sinal de interação
		interaction_finished.emit(InteractableType.Lamp)
