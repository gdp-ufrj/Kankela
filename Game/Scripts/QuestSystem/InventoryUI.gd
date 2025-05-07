extends Control

@onready var player = get_node("../../")

@onready var lista_itens = $PainelInventario/ScrollContainer/ListaItens
@onready var descricao_item = $PainelInventario/PainelDescricao/Descricao
@onready var nome_item = $PainelInventario/PainelDescricao/Nome
var quest_manager = Engine.get_singleton("QuestManager")

var item_id_selecionado = null
var botoes_itens = []

func _ready():
	atualizar_inventario()
	# Conecta sinal para atualização do inventário
	quest_manager.inventario_atualizado.connect(atualizar_inventario)


func atualizar_inventario():
	# Limpa itens anteriores
	for botao in botoes_itens:
		botao.queue_free()
	botoes_itens.clear()
	
	# Adiciona itens do inventário
	for item_id in quest_manager.inventario:
		var info_item = quest_manager.obter_info_item(item_id)
		
		# Verifica se o dicionário está vazio de forma correta e pula itens inválidos ou já usados
		if info_item.size() == 0 or info_item.has("usado") and info_item.usado:
			continue
			
		var botao = Button.new()
		botao.text = info_item.nome
		botao.custom_minimum_size = Vector2(200, 40)
		botao.pressed.connect(_on_item_selecionado.bind(item_id))
		
		if info_item.icone:
			var textura = TextureRect.new()
			textura.texture = info_item.icone
			textura.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
			textura.custom_minimum_size = Vector2(32, 32)
			textura.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			var hbox = HBoxContainer.new()
			hbox.add_child(textura)
			
			var label = Label.new()
			label.text = info_item.nome
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(label)
			
			botao.add_child(hbox)
		
		lista_itens.add_child(botao)
		botoes_itens.append(botao)
	
	# Reset descrição
	nome_item.text = ""
	descricao_item.text = ""

func _on_item_selecionado(item_id):
	item_id_selecionado = item_id
	var info_item = quest_manager.obter_info_item(item_id)
	
	# Verifica se o dicionário está vazio de forma correta
	if info_item.size() > 0:
		nome_item.text = info_item.nome
		descricao_item.text = info_item.descricao

func _on_fechar_pressed():
	player.InventoryMenu()
