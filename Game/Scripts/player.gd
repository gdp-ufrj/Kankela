extends CharacterBody2D

const SPEED = 200.0

@onready var animacao := $Anim as AnimatedSprite2D
@onready var cutscene_mode

# Variável para rastrear a última animação de caminhada
var last_walk_animation: String = "Walk_front"

# Função auxiliar para obter a animação idle correspondente
func get_idle_animation() -> String:
	match last_walk_animation:
		"Walk_front":
			return "Idle_front"
		"Walk_back":
			return "Idle_back"
		"Walk_side":
			return "Idle_side"
		_:
			return "Idle_front" # Fallback

# Variáveis para controle de cutscenes avançadas
var is_moving_to_position: bool = false
var target_position: Vector2
var cutscene_tween: Tween

# Referência à tela, controlador e sinal da lupa
signal activate_lupa(is_lupa_active: bool)
@onready var lupa = $Camera2D/Lupa
@onready var is_lupa_active = false

# Variáveis para controle da tecla L
var can_use_lupa: bool = false
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

	# Nova lógica para a tecla L
	if can_use_lupa: handle_lupa_input(_delta)

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

			# Sistema de animações baseado na direção
			var current_animation: String
			
			# Prioridade para movimentos verticais
			if direction_y > 0: # Movendo para baixo
				current_animation = "Walk_front"
			elif direction_y < 0: # Movendo para cima
				current_animation = "Walk_back"
			else: # Apenas movimento horizontal
				current_animation = "Walk_side"
			
			# Aplica a animação e salva como última animação
			$Anim.play(current_animation)
			last_walk_animation = current_animation

			# Vira o sprite horizontalmente conforme a direção
			if direction.x > 0:
				animacao.scale.x = animacao.scale.x if animacao.scale.x > 0 else -animacao.scale.x
			elif direction.x < 0:
				animacao.scale.x = animacao.scale.x if animacao.scale.x < 0 else -animacao.scale.x

		else:
			# Desacelera suavemente até parar
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)

			# Animação de idle baseada na última animação de caminhada
			$Anim.play(get_idle_animation())

		# Aplicando o movimento
		move_and_slide()

		# Verifica interação
		if Input.is_action_just_pressed("ui_select") and objeto_interagivel:
			$Anim.play(get_idle_animation())
			self.interact_with_objects()
	
	# Durante cutscenes, ainda aplica o movimento se estiver sendo controlado por Tween
	elif cutscene_mode and is_moving_to_position:
		move_and_slide()


func start_cutscene(dialogue_resource: DialogueResource, title: String = "", move_to_position: Vector2 = Vector2.ZERO, new_scene_path: String = "", movement_speed: float = 50.0) -> void:
	cutscene_mode = true
	# Move o player para a posição especificada (se fornecida)
	if move_to_position != Vector2.ZERO:
		await move_player_to_position(move_to_position, movement_speed)
	
	# Exibe o diálogo (se fornecido)
	if dialogue_resource != null:
		DialogueManager.show_dialogue_balloon(dialogue_resource, title)
		await DialogueManager.dialogue_ended
	
	# Muda de cena (se especificada)
	if new_scene_path != "":
		change_scene_to(new_scene_path)
	
	cutscene_mode = false

# Método auxiliar para mostrar diálogo a partir de uma string
func start_cutscene_from_string(text: String, title: String = "") -> void:
	cutscene_mode = true

	var dialogue_resource = DialogueManager.create_resource_from_text(text)
	DialogueManager.show_dialogue_balloon(dialogue_resource, title)
	await DialogueManager.dialogue_ended

	cutscene_mode = false


# Método para mover o player para uma posição específica durante cutscenes
func move_player_to_position(target_pos: Vector2, movement_speed: float = 50.0):
	if cutscene_tween:
		cutscene_tween.kill()
	
	cutscene_tween = create_tween()
	target_position = target_pos
	is_moving_to_position = true
	
	# Calcula a direção para a animação
	var direction = (target_position - global_position).normalized()
	
	# Define a animação baseada na direção
	if direction != Vector2.ZERO:
		# Sistema de animações baseado na direção (mesma lógica do movimento normal)
		var current_animation: String
		
		# Prioridade para movimentos verticais
		if direction.y > 0: # Movendo para baixo
			current_animation = "Walk_front"
		elif direction.y < 0: # Movendo para cima
			current_animation = "Walk_back"
		else: # Apenas movimento horizontal
			current_animation = "Walk_side"
		
		$Anim.play(current_animation)
		last_walk_animation = current_animation
		
		# Vira o sprite horizontalmente conforme a direção
		if direction.x > 0:
			animacao.scale.x = animacao.scale.x if animacao.scale.x > 0 else -animacao.scale.x
		elif direction.x < 0:
			animacao.scale.x = animacao.scale.x if animacao.scale.x < 0 else -animacao.scale.x
	
	# Calcula o tempo baseado na distância e velocidade
	var distance = global_position.distance_to(target_position)
	var duration = distance / movement_speed
	
	# Move o player usando Tween
	cutscene_tween.tween_property(self, "global_position", target_position, duration)
	await cutscene_tween.finished
	
	# Para a animação quando chegar ao destino
	$Anim.play(get_idle_animation())
	is_moving_to_position = false


# Método para mudança de cena durante cutscenes
func change_scene_to(scene_path: String) -> void:
	# Verifica se o SceneManager está disponível como singleton/autoload
	if has_node("/root/SceneManager"):
		var scene_manager = get_node("/root/SceneManager")
		if scene_manager.has_method("load_game_scene"):
			scene_manager.load_game_scene(scene_path)
		else:
			# Fallback para mudança direta
			get_tree().change_scene_to_file(scene_path)
	else:
		# Mudança direta de cena
		get_tree().change_scene_to_file(scene_path)

# ------------------------------------------------------------------------------

# Versão simplificada do método original para compatibilidade
func start_simple_cutscene(dialogue_resource: DialogueResource, title: String = "") -> void:
	await start_cutscene(dialogue_resource, title)


# Métodos de conveniência para casos específicos de cutscenes

# Apenas move o player para uma posição
func start_movement_cutscene(move_to_position: Vector2, movement_speed: float = 200.0) -> void:
	await start_cutscene(null, "", move_to_position, "", movement_speed)

# Apenas muda de cena
func start_scene_change_cutscene(new_scene_path: String) -> void:
	await start_cutscene(null, "", Vector2.ZERO, new_scene_path)

# Move player e depois muda de cena
func start_move_and_change_scene_cutscene(move_to_position: Vector2, new_scene_path: String, movement_speed: float = 200.0) -> void:
	await start_cutscene(null, "", move_to_position, new_scene_path, movement_speed)

# Diálogo e depois mudança de cena
func start_dialogue_and_scene_change_cutscene(dialogue_resource: DialogueResource, new_scene_path: String, title: String = "") -> void:
	await start_cutscene(dialogue_resource, title, Vector2.ZERO, new_scene_path)

# Cutscene completa: movimento, diálogo e mudança de cena
func start_full_cutscene(dialogue_resource: DialogueResource, move_to_position: Vector2, new_scene_path: String, title: String = "", movement_speed: float = 200.0) -> void:
	await start_cutscene(dialogue_resource, title, move_to_position, new_scene_path, movement_speed)

# Método para parar uma cutscene em andamento (útil para debugging ou situações especiais)
func stop_cutscene() -> void:
	if cutscene_tween:
		cutscene_tween.kill()
	is_moving_to_position = false
	cutscene_mode = false
	$Anim.play(get_idle_animation())

# Método para verificar se está em uma cutscene
func is_in_cutscene() -> bool:
	return cutscene_mode

# Método para verificar se está se movendo durante uma cutscene
func is_cutscene_moving() -> bool:
	return is_moving_to_position

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
