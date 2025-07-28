extends Control

@onready var windowed = get_node("Panel/MainContainer/VideoSection/HBoxContainer/Janela")
@onready var borderless = get_node("Panel/MainContainer/VideoSection/HBoxContainer/SemBordas")
@onready var fullscreen = get_node("Panel/MainContainer/VideoSection/HBoxContainer/TelaCheia")
@onready var resolution = get_node("Panel/MainContainer/VideoSection/tipo_resolucoes")
@onready var screen_size = DisplayServer.screen_get_size() # Tamanho da tela atual
@onready var window_menu = get_node("Panel/MainContainer/VideoSection/HBoxContainer")
@onready var game_viewport = get_tree().root.find_child("GameViewport", true, false)

# Controles de volume
@onready var master_slider = get_node("Panel/MainContainer/AudioSection/MasterSlider")
@onready var bg_slider = get_node("Panel/MainContainer/AudioSection/BGSlider")
@onready var sfx_slider = get_node("Panel/MainContainer/AudioSection/SFXSlider")


# Carrega as configurações alteradas
func load_settings():
	resolution.disabled = !GlobalSettings.is_windowed
	
	resolution.select(GlobalSettings.window_size)
	window_menu.get_child(GlobalSettings.window_type).button_pressed = true
	change_checkboxes(window_menu.get_child(GlobalSettings.window_type))
	
	# Carrega configurações de volume
	master_slider.value = GlobalSettings.master_volume
	bg_slider.value = GlobalSettings.bg_volume
	sfx_slider.value = GlobalSettings.sfx_volume
	
	# Aplica os volumes aos buses
	apply_volume_settings()


# Salva as alterações feitas nas configurações
func save_settings():
	GlobalSettings.window_size = resolution.get_selected_id()
	
	# Salva configurações de volume
	GlobalSettings.master_volume = master_slider.value
	GlobalSettings.bg_volume = bg_slider.value
	GlobalSettings.sfx_volume = sfx_slider.value


func _ready():
	load_settings()
	# Define um tamanho mínimo pra janela do jogo
	DisplayServer.window_set_min_size(Vector2i(640, 360))
	

# Definindo a resolução do jogo
func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			change_viewport(1920, 1080)
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
			change_viewport(1600, 900)
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
			change_viewport(1280, 720)
		3:
			DisplayServer.window_set_size(Vector2i(1152, 648))
			change_viewport(1152, 648)
		4:
			DisplayServer.window_set_size(Vector2i(640, 360))
			change_viewport(640, 360)
	center_window()

func change_viewport(size_x, size_y):
	if game_viewport:
		game_viewport.set_size(Vector2(size_x, size_y)) # ou outro tamanho desejado
	else:
		print("GameViewport não encontrado!")

# Centraliza a janela
func center_window():
	var window_size = DisplayServer.window_get_size() # Tamanho atual da janela
	var centered_position = (screen_size - window_size) / 2 # Calcula a posição central da tela baseado no tamanho da tela e da janela
	DisplayServer.window_set_position(centered_position) # Centraliza a posição da janela


# Definindo se será no modo janela ou tela cheia ou sem bordas
func change_checkboxes(node):
	for i in range(window_menu.get_child_count()): # Pega a quantidade de filhos do nó pai (HBoxContainer)
		if node == window_menu.get_child(i):
			window_menu.get_child(i).disabled = true
			GlobalSettings.window_type = i
		else:
			window_menu.get_child(i).button_pressed = false
			window_menu.get_child(i).disabled = false


func _on_windowed_pressed() -> void:
	resolution.disabled = false
	GlobalSettings.is_windowed = true
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
	change_checkboxes(windowed)
	apply_window_mode()


func _on_borderless_pressed() -> void:
	resolution.disabled = true
	GlobalSettings.is_windowed = false
	DisplayServer.window_set_size(screen_size)
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, true)
	change_checkboxes(borderless)
	center_window()


func _on_full_screen_pressed() -> void:
	resolution.disabled = true
	GlobalSettings.is_windowed = false
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	change_checkboxes(fullscreen)


func apply_window_mode() -> void:
	match resolution.get_selected_id():
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		3:
			DisplayServer.window_set_size(Vector2i(1152, 648))
		4:
			DisplayServer.window_set_size(Vector2i(640, 360))
	center_window()


func _on_back_pressed() -> void:
	self.visible = false
	save_settings()


# Aplica as configurações de volume aos buses de áudio
func apply_volume_settings():
	var master_db = linear_to_db(GlobalSettings.master_volume)
	var bg_db = linear_to_db(GlobalSettings.bg_volume)
	var sfx_db = linear_to_db(GlobalSettings.sfx_volume)
	
	AudioServer.set_bus_volume_db(0, master_db) # Bus Master
	AudioServer.set_bus_volume_db(1, bg_db) # Bus BG
	AudioServer.set_bus_volume_db(2, sfx_db) # Bus SFX


# Callbacks dos sliders de volume
func _on_master_slider_value_changed(value: float) -> void:
	GlobalSettings.master_volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_bg_slider_value_changed(value: float) -> void:
	GlobalSettings.bg_volume = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	GlobalSettings.sfx_volume = value
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
