extends CharacterBody2D


const SPEED = 300.0

@onready var animacao := $Anim as AnimatedSprite2D
@onready var cutscene_mode

# Referência a tela de pause e controlador
@onready var pause_menu = $Camera2D/Pause
@onready var paused = false

# Referências às telas de inventário e missões
@onready var inventory_ui = $Camera2D/InventoryUI
@onready var inventory_open = false
@onready var quest_log_ui = $Camera2D/QuestLogUI
@onready var quest_log_open = false

# Área de detecção de interações
@onready var area_interacao := $AreaInteracao as Area2D

# Objeto atual com o qual o jogador pode interact
var objeto_interagivel: Array[Node] = []


func _ready() -> void:
	# Inicia a cutscene inicial
	#start_cutscene(preload("res://Dialogues/Start.dialogue"))
	# Conecta o sinal para detectar quando um objeto entra na área de interação
	area_interacao.body_entered.connect(_on_area_interacao_body_entered)
	area_interacao.body_exited.connect(_on_area_interacao_body_exited)

	# Desativa o ícone de interação inicialmente
	$IconeInteracao.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !cutscene_mode:
		PauseMenu()
		
	if Input.is_action_just_pressed("inventory") and !cutscene_mode and !paused and inventory_ui:
		InventoryMenu()
		
	if Input.is_action_just_pressed("quest_log") and !cutscene_mode and !paused and quest_log_ui:
		QuestLogMenu()


func PauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		#get_tree().paused = false
	else:
		pause_menu.show()
		Engine.time_scale = 0
		#get_tree().paused = true
	paused = !paused

func InventoryMenu():
	if inventory_open:
		inventory_ui.hide()
		Engine.time_scale = 1
	else:
		inventory_ui.show()
		inventory_ui.get_script().atualizar_inventario()
		Engine.time_scale = 0
	inventory_open = !inventory_open

func QuestLogMenu():
	if quest_log_open:
		quest_log_ui.hide()
		Engine.time_scale = 1
	else:
		quest_log_ui.show()
		quest_log_ui.get_script().atualizar_quest_log("")
		Engine.time_scale = 0
	quest_log_open = !quest_log_open


func _physics_process(_delta: float) -> void:
	if !cutscene_mode and !paused:
		# Movimentação no eixo X e no eixo Y  
		var direction_x := Input.get_axis("ui_left", "ui_right")
		var direction_y := Input.get_axis("ui_up", "ui_down")
		
		# Combina as direções em um vetor e normaliza para movimento diagonal
		var direction := Vector2(direction_x, direction_y).normalized()
		
		if direction != Vector2.ZERO:
			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
			
			# Animação de andar
			$Anim.play("Andando")
			
			# Vira o sprite horizontalmente conforme a direção
			if direction.x > 0:
				animacao.scale.x = 1
			elif direction.x < 0:
				animacao.scale.x = -1
				
		else:
			# Desacelera suavemente até parar
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
			# Animação de idle (parado)
			$Anim.play("Parada")

		# Aplicando o movimento
		move_and_slide()

		# Verifica interação
		if Input.is_action_just_pressed("ui_select") and objeto_interagivel:
			$Anim.play("Parada")
			self.interact_with_objects()


func start_cutscene(dialogue_resource: DialogueResource, title: String = "") -> void:
	cutscene_mode = true
	DialogueManager.show_dialogue_balloon(dialogue_resource, title)
	await DialogueManager.dialogue_ended
	cutscene_mode = false


# Chamado quando um objeto entra na área de interação
func _on_area_interacao_body_entered(body: Node) -> void:
	# Verifica se o objeto possui a interface de interação
	if body is ObjetoInterativo:
		objeto_interagivel.push_back(body)
		$IconeInteracao.visible = true
		
		# Conecta o sinal do objeto interativo à função de tratamento
		if not body.interaction_finished.is_connected(_on_objeto_interaction_finished):
			body.interaction_finished.connect(_on_objeto_interaction_finished)
		
		# Ativa o delineado do objeto se for o primeiro na lista
		if body == objeto_interagivel[0]:
			body.ativar_delineado()


# Chamado quando um objeto sai da área de interação
func _on_area_interacao_body_exited(body: Node) -> void:
	var index = objeto_interagivel.find(body)
	if index != -1:
		objeto_interagivel.pop_at(index)

		# Se o objeto que saiu tinha delineado, desativa
		if index == 0:
			body.desativar_delineado()

		if objeto_interagivel.size() > 0:
			$IconeInteracao.visible = true
			objeto_interagivel[0].ativar_delineado()
		else:
			$IconeInteracao.visible = false


# Método para interact com o objeto atual
func interact_with_objects() -> void:
	objeto_interagivel[0].interact(self)


# Função chamada quando o sinal interaction_finished é emitido
func _on_objeto_interaction_finished(type: ObjetoInterativo.InteractableType) -> void:
	match type:
		ObjetoInterativo.InteractableType.None:
			print("Interação básica concluída")
			
		ObjetoInterativo.InteractableType.Dialogue:
			print("Diálogo concluído")
			
		ObjetoInterativo.InteractableType.Item:
			print("Item coletado")
			objeto_interagivel.pop_front()
			if objeto_interagivel.size() > 0:
				$IconeInteracao.visible = true
				objeto_interagivel[0].ativar_delineado()
			else:
				$IconeInteracao.visible = false
			
		ObjetoInterativo.InteractableType.Door:
			print("Porta :)")
			
		_: # Caso padrão
			pass
