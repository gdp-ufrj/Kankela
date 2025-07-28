extends Node


# Dados da configuração
@onready var is_windowed: bool = true # Define se está em modo janela
@onready var window_size: int = 4 # Define o tipo de tamanho da janela
@onready var window_type: int = 0 # Define o modo de janela (windowed, borderless, fullscreen)

# Dados de volume dos buses de áudio
@onready var master_volume: float = 1.0 # Volume do bus Master (0.0 a 1.0)
@onready var bg_volume: float = 0.5 # Volume do bus BG (0.0 a 1.0)
@onready var sfx_volume: float = 0.2 # Volume do bus SFX (0.0 a 1.0)


func _ready():
	# Aplica as configurações de volume ao inicializar o jogo
	apply_audio_settings()


# Aplica as configurações de volume aos buses de áudio
func apply_audio_settings():
	var master_db = linear_to_db(master_volume)
	var bg_db = linear_to_db(bg_volume)
	var sfx_db = linear_to_db(sfx_volume)
	
	AudioServer.set_bus_volume_db(0, master_db) # Bus Master
	AudioServer.set_bus_volume_db(1, bg_db) # Bus BG
	AudioServer.set_bus_volume_db(2, sfx_db) # Bus SFX
