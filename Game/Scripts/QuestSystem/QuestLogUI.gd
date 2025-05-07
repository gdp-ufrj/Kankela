extends Control

@onready var player = get_node("../../")

@onready var titulo_missao = $PainelQuest/TituloMissao
@onready var descricao_missao = $PainelQuest/DescricaoMissao
@onready var lista_objetivos = $PainelQuest/ListaObjetivos/VBoxContainer
var quest_manager = Engine.get_singleton("QuestManager")

func _ready():
	# Esconde a interface inicialmente
	visible = false
	# Conecta ao sinal de missão atualizada
	quest_manager.missao_atualizada.connect(atualizar_quest_log)
	# Conecta também ao sinal de item coletado para atualizar em tempo real
	quest_manager.item_coletado.connect(_on_item_coletado)
	quest_manager.item_usado.connect(_on_item_usado)
	atualizar_quest_log("")

# Chamado quando um item é coletado
func _on_item_coletado(_item_id):
	atualizar_quest_log("")

# Chamado quando um item é usado
func _on_item_usado(_item_id):
	atualizar_quest_log("")

func atualizar_quest_log(_quest_id):
	# Limpa objetivos anteriores
	for child in lista_objetivos.get_children():
		child.queue_free()
	
	# Obtém missão ativa
	var quest = quest_manager.obter_missao_ativa()
	
	if quest:
		titulo_missao.text = quest.titulo
		descricao_missao.text = quest.descricao
		
		# Mostra itens necessários para a missão
		for item_id in quest.itens_necessarios:
			if quest_manager.todos_itens.has(item_id):
				var info_item = quest_manager.obter_info_item(item_id)
				var hbox = HBoxContainer.new()
				
				var check = CheckBox.new()
				check.button_pressed = info_item.has("coletado") and info_item.coletado
				check.disabled = true
				hbox.add_child(check)
				
				var label = Label.new()
				label.text = "Coletar " + info_item.nome
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(label)
				
				lista_objetivos.add_child(hbox)
	else:
		titulo_missao.text = "Nenhuma missão ativa"
		descricao_missao.text = ""

func _on_fechar_pressed():
	player.QuestLogMenu()
