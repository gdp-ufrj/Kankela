class_name NPC extends "res://Scripts/ObjetoInterativo.gd"

# Nome do NPC
@export var nome_npc: String = "NPC"

# Referência ao arquivo de diálogo para o Dialogue Manager (se presente)
@export_file("*.dialogue") var arquivo_dialogo: String
# Título do nó inicial de diálogo
@export var titulo_dialogo: String = ""

var can_interact: bool = true
var interaction_debound: float = 0.05

func _ready() -> void:
	$Label.text = nome_npc

func interact(_player: Node) -> void:
	if not can_interact:
		return

	can_interact = false
	_player.get_node("Anim").play("Parada")
	_player.get_node("IconeInteracao").visible = false
	desativar_delineado()

	# Exibe mensagem no console
	print(nome_npc + " está falando com você.")
	
	# Se o Dialogue Manager estiver disponível, inicia o diálogo
	if Engine.has_singleton("DialogueManager"):
		if arquivo_dialogo and arquivo_dialogo != "":
			_player.start_cutscene(load(arquivo_dialogo), titulo_dialogo)
	else:
		# Caso o Dialogue Manager não esteja disponível, exibe mensagem padrão
		print("Sistema de diálogo não disponível.")

	await DialogueManager.dialogue_ended
	get_tree().create_timer(interaction_debound).timeout.connect(func(): can_interact = true)
	
	_player.get_node("IconeInteracao").visible = true
	ativar_delineado()
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Dialogue)
