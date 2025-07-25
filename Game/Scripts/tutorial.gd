extends Node2D

@onready var fusiveis_conectados: Array = [false, false, false]
@onready var luzes_acesas: Array = [false, false, false]

func _ready():
	# Inicia a cutscene inicial
	%Player.start_cutscene(preload("res://Dialogues/Start.dialogue"))
	
	# Iniciando a missão do tutorial
	QuestManager.iniciar_missao("coletar_fusiveis")
	
	# Desativa a chave para não conseguir pegá-la antes do tempo
	get_node("Chave/CollisionShape2D").disabled = true
	
	# Conecta o sinal de cada lâmpada nesse script
	for luz in get_children():
		if luz.has_signal("interagida"):
			luz.interagida.connect(_on_lampada_interagida)


# Chamado quando interage com a lâmpada
func _on_lampada_interagida(index):
	if QuestManager.todas_missoes["ligar_lampadas"].is_em_andamento():
		luzes_acesas[index] = !luzes_acesas[index]
		if index != 1:
			luzes_acesas[1] = !luzes_acesas[1]
		
		for i in range(1, 4):
			if luzes_acesas[i - 1]:
				get_node("Lampada" + str(i)).sprite.texture = load("res://Assets/Visuals/Scenarios/luminária_acesa.png")
				if !luzes_acesas.has(false):
					QuestManager.completar_missao("ligar_lampadas")
					get_node("Chave").visible = true
					get_node("Chave/CollisionShape2D").disabled = false
					print("Missão de luzes concluída!")
			else:
				get_node("Lampada" + str(i)).sprite.texture = load("res://Assets/Visuals/Scenarios/luminária_apagada.png")
		
		
	else:
		print("Não é possível acender: fusível ausente")
