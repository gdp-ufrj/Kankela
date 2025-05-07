extends Node

# Sinais para notificar mudanças
signal missao_atualizada(quest_id: String)
signal item_coletado(item_id: String)
signal item_usado(item_id: String)
signal inventario_atualizado

# Lista de todas as missões no jogo
var todas_missoes: Dictionary = {}
# Missão ativa atual
var missao_ativa: Quest = null
# Inventário do jogador
var inventario: Array[String] = []
# Lista de todos os itens existentes no jogo
var todos_itens: Dictionary = {}
# Caminho para o arquivo JSON de itens
var caminho_arquivo_itens = "res://Data/itens.json"
# Caminho para o arquivo JSON de missões
var caminho_arquivo_missoes = "res://Data/missoes.json"

func _ready() -> void:
	if not Engine.has_singleton("QuestManager"):
		Engine.register_singleton("QuestManager", self)
	
	# Carrega itens e missões do .json (melhor jeito que eu pensei da gente criar as coisas)
	_carregar_dados_json()

# Adiciona uma missão ao sistema
func adicionar_missao(quest: Quest) -> void:
	todas_missoes[quest.id] = quest
	
# Começa uma missão específica
func iniciar_missao(quest_id: String) -> void:
	if todas_missoes.has(quest_id):
		var quest = todas_missoes[quest_id]
		quest.iniciar()
		missao_ativa = quest
		missao_atualizada.emit(quest_id)
		print("Missão iniciada: " + quest.titulo)

# Completa uma missão específica
func completar_missao(quest_id: String) -> void:
	if todas_missoes.has(quest_id):
		var quest = todas_missoes[quest_id]
		
		# Marca todos os itens necessários como usados
		if quest.itens_necessarios.size() > 0:
			for item_id in quest.itens_necessarios:
				usar_item(item_id)
		
		quest.completar()
		missao_atualizada.emit(quest_id)
		print("Missão completa: " + quest.titulo)
		
		# Inicia próxima missão automaticamente, se tiver registrada no .json
		if quest.proxima_missao != "" and todas_missoes.has(quest.proxima_missao):
			iniciar_missao(quest.proxima_missao)

# Obtém a missão atual (não tenho usado muito pq parece q dá um erro no dialogue manager)
func obter_missao_ativa() -> Quest:
	return missao_ativa

# Registra um item no sistema
func adicionar_item_sistema(item_id: String, nome: String, descricao: String, icone: Texture2D) -> void:
	if not todos_itens.has(item_id):
		todos_itens[item_id] = {
			"id": item_id,
			"nome": nome,
			"descricao": descricao,
			"icone": icone,
			"coletado": false,
			"usado": false
		}
	
# Coleta um item para o inventário
func coletar_item(item_id: String) -> bool:
	if todos_itens.has(item_id):
		var item = todos_itens[item_id]

		if not item.coletado:
			item.coletado = true
			if not inventario.has(item_id):
				inventario.append(item_id)

			item_coletado.emit(item_id)
			inventario_atualizado.emit()
			return true
	return false
	
# Usa um item do inventário
func usar_item(item_id: String) -> bool:
	if todos_itens.has(item_id) and not todos_itens[item_id].usado:
		if inventario.has(item_id):
			todos_itens[item_id].usado = true
			item_usado.emit(item_id)
			inventario_atualizado.emit()
			return true
	return false
	
# Verifica se o jogador possui um item específico no inventário que ainda não usou
func tem_item_disponivel(item_id: String) -> bool:
	if todos_itens.has(item_id):
		return todos_itens[item_id].coletado and not todos_itens[item_id].usado and inventario.has(item_id)
	return false

# Verifica se o jogador tem todos os itens necessários para a missão
func tem_itens_para_missao(quest_id: String) -> bool:
	if not todas_missoes.has(quest_id):
		return false
		
	var quest = todas_missoes[quest_id]
	for item_id in quest.itens_necessarios:
		if not tem_item_disponivel(item_id):
			return false
	return true

# Obtém informações sobre um item específico
func obter_info_item(item_id: String) -> Dictionary:
	if todos_itens.has(item_id):
		return todos_itens[item_id]
	return {}

# Carrega os itens e missões a partir do .json
func _carregar_dados_json() -> void:
	# Carregar itens
	if ResourceLoader.exists(caminho_arquivo_itens):
		var arquivo_json = FileAccess.open(caminho_arquivo_itens, FileAccess.READ)
		if arquivo_json:
			var json_text = arquivo_json.get_as_text()
			var json = JSON.new()
			var erro = json.parse(json_text)
			if erro == OK:
				var dados_itens = json.get_data()
				for item_data in dados_itens:
					var icone: Texture2D = null
					if item_data.has("icone_path") and item_data.icone_path != "":
						icone = load(item_data.icone_path)
						
					adicionar_item_sistema(
						item_data.id,
						item_data.nome,
						item_data.descricao,
						icone
					)
				print("Itens carregados do JSON com sucesso!")
			else:
				push_error("Erro ao analisar o JSON de itens: " + str(erro) + " na linha " + str(json.get_error_line()))
	else:
		push_warning("Arquivo de itens não encontrado: " + caminho_arquivo_itens)
	
	# Carregar missões
	if ResourceLoader.exists(caminho_arquivo_missoes):
		var arquivo_json = FileAccess.open(caminho_arquivo_missoes, FileAccess.READ)
		if arquivo_json:
			var json_text = arquivo_json.get_as_text()
			var json = JSON.new()
			var erro = json.parse(json_text)
			if erro == OK:
				var dados_missoes = json.get_data()
				for missao_data in dados_missoes:
					var missao = Quest.new()
					missao.id = missao_data.id
					missao.titulo = missao_data.titulo
					missao.descricao = missao_data.descricao
					
					# Verifica e carrega itens necessários
					if missao_data.has("itens_necessarios"):
						var itens_array: Array[String] = []
						for item in missao_data.itens_necessarios:
							itens_array.append(item)
						missao.itens_necessarios = itens_array
					
					# Verificar e carregar próxima missão
					if missao_data.has("proxima_missao"):
						missao.proxima_missao = missao_data.proxima_missao
					
					# Verificar e carregar diálogos específicos
					if missao_data.has("arquivo_dialogo_completo"):
						missao.arquivo_dialogo_completo = missao_data.arquivo_dialogo_completo
					if missao_data.has("titulo_dialogo_completo"):
						missao.titulo_dialogo_completo = missao_data.titulo_dialogo_completo
						
					adicionar_missao(missao)
				print("Missões carregadas do JSON com sucesso!")
			else:
				push_error("Erro ao analisar o JSON de missões: " + str(erro) + " na linha " + str(json.get_error_line()))
	else:
		push_warning("Arquivo de missões não encontrado: " + caminho_arquivo_missoes)

# Salvar o estado do jogo (missões e inventário) (NÃO TESTEI)
func salvar_estado() -> Dictionary:
	var missoes_salvas = {}
	var itens_salvos = {}
	
	# Salvar estado das missões
	for id in todas_missoes:
		var quest = todas_missoes[id]
		missoes_salvas[id] = {
			"estado": quest.estado
		}
	
	# Salvar estado dos itens
	for id in todos_itens:
		var item = todos_itens[id]
		itens_salvos[id] = {
			"coletado": item.coletado,
			"usado": item.usado
		}
	
	return {
		"missoes": missoes_salvas,
		"itens": itens_salvos,
		"inventario": inventario,
		"missao_ativa": missao_ativa.id if missao_ativa else ""
	}

# Carregar o estado do jogo (NÃO TESTEI)
func carregar_estado(dados: Dictionary) -> void:
	if dados.has("missoes"):
		for id in dados["missoes"]:
			if todas_missoes.has(id):
				todas_missoes[id].estado = dados["missoes"][id]["estado"]
	
	if dados.has("itens"):
		for id in dados["itens"]:
			if todos_itens.has(id):
				todos_itens[id].coletado = dados["itens"][id]["coletado"]
				todos_itens[id].usado = dados["itens"][id]["usado"]
	
	if dados.has("inventario"):
		inventario = dados["inventario"]
	
	if dados.has("missao_ativa") and dados["missao_ativa"] != "":
		missao_ativa = todas_missoes[dados["missao_ativa"]] if todas_missoes.has(dados["missao_ativa"]) else null
	
	# Emitir sinal para atualizar interfaces
	inventario_atualizado.emit()
	if missao_ativa:
		missao_atualizada.emit(missao_ativa.id)
