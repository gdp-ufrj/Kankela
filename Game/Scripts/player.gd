extends CharacterBody2D


const SPEED = 300.0

@onready var animacao := $Anim as AnimatedSprite2D
@onready var cutscene_mode

# Referência à tela, controlador e sinal da lupa
signal activate_lupa(is_lupa_active: bool)
@onready var lupa = $Camera2D/Lupa
@onready var is_lupa_active = false

# Variáveis para controle da tecla L
var l_key_pressed_time: float = 0.0
var l_key_hold_threshold: float = 0.5 # 0.5 segundos para considerar "segurar"
var l_key_just_pressed: bool = false

# Referência a tela de pause e controlador
@onready var pause_menu = $Camera2D/Pause
@onready var paused = false

# Referências às telas de inventário e missões
@onready var inventory_ui = $Camera2D/InventoryUI
@onready var is_inventory_open = false
@onready var is_quest_log_ui = $Camera2D/QuestLogUI
@onready var quest_log_open = false

# Área de detecção de interações
@onready var area_interacao := $AreaInteracao as Area2D

# Objeto atual com o qual o jogador pode interact
var objeto_interagivel: Array[Node] = []
@onready var interacting: bool = false

func _ready() -> void:
	# Inicia a cutscene inicial
	start_cutscene(preload("res://Dialogues/Start.dialogue"))

	# Conecta o sinal para detectar quando um objeto entra na área de interação
	area_interacao.body_entered.connect(_on_area_interacao_body_entered)
	area_interacao.body_exited.connect(_on_area_interacao_body_exited)
	
	# Conecta o sinal da lupa para mudanças de tipo
	lupa.lupa_type_changed.connect(_on_lupa_type_changed)

	# Conecta o sinal para objetos secretos receberem o estado da lupa
	var objetos_secretos = get_tree().get_nodes_in_group("objeto_secreto")
	for objeto in objetos_secretos:
		self.activate_lupa.connect(objeto._on_player_activate_lupa)
		lupa.lupa_type_changed.connect(objeto._on_lupa_type_changed)

	# Desativa o ícone de interação inicialmente
	$IconeInteracao.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !cutscene_mode and !interacting:
		PauseMenu()

	if Input.is_action_just_pressed("inventory") and !cutscene_mode and !paused and inventory_ui and !interacting:
		InventoryMenu()

	if Input.is_action_just_pressed("quest_log") and !cutscene_mode and !paused and is_quest_log_ui and !interacting:
		QuestLogMenu()

	# Nova lógica para a tecla L
	handle_lupa_input(_delta)

func handle_lupa_input(delta: float):
	if Input.is_action_just_pressed("lupa"):
		l_key_just_pressed = true
		l_key_pressed_time = 0.0
	
	if Input.is_action_pressed("lupa") and l_key_just_pressed:
		l_key_pressed_time += delta
		
		# Se segurou por tempo suficiente, desliga imediatamente
		if l_key_pressed_time >= l_key_hold_threshold:
			lupa.turn_off_lupa()
			update_lupa_state()
			l_key_just_pressed = false
	
	if Input.is_action_just_released("lupa") and l_key_just_pressed:
		# Se soltou antes do threshold, alterna entre tipos
		if l_key_pressed_time < l_key_hold_threshold:
			lupa.cycle_lupa_type()
			update_lupa_state()
		l_key_just_pressed = false

func update_lupa_state():
	is_lupa_active = lupa.is_lupa_active()
	emit_signal("activate_lupa", is_lupa_active)

func _on_lupa_type_changed(_lupa_type):
	# Atualiza o estado interno quando o tipo da lupa muda
	is_lupa_active = lupa.is_lupa_active()
	emit_signal("activate_lupa", is_lupa_active)

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
	if is_inventory_open:
		inventory_ui.hide()
		Engine.time_scale = 1
	else:
		inventory_ui.show()
		inventory_ui.get_script().atualizar_inventario()
		Engine.time_scale = 0
	is_inventory_open = !is_inventory_open

func QuestLogMenu():
	if quest_log_open:
		is_quest_log_ui.hide()
		Engine.time_scale = 1
	else:
		is_quest_log_ui.show()
		is_quest_log_ui.get_script().atualizar_quest_log("")
		Engine.time_scale = 0
	quest_log_open = !quest_log_open


func _physics_process(_delta: float) -> void:
	if !cutscene_mode and !paused and !interacting:
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

		ObjetoInterativo.InteractableType.Lamp:
			print("Interagiu com uma lâmpada!")

		ObjetoInterativo.InteractableType.Clues:
			print("Terminou de ver a pista!")

		_: # Caso padrão
			pass
