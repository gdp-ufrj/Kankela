extends Node

# Caminho direto ao GameRoot
var game_root: Node2D = null
# Player de áudio para efeitos sonoros
var audio_player: AudioStreamPlayer = null

#transição de cenário
@onready var transition: CanvasLayer = get_node("/root/TransicaoLayer")

func setup(root: Node2D) -> void:
	game_root = root
	# Cria o AudioStreamPlayer se não existir
	if audio_player == null:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)

func load_game_scene(path: String) -> void:
	if game_root == null:
		push_error("GameRoot não configurado!")
		return

	# Inicia a transição
	transition.fade_out()
	await transition.fade_out()
	# Pequeno delay
	await get_tree().create_timer(0.5).timeout

	if game_root.get_child_count() > 0:
		for child in game_root.get_children():
			child.queue_free()

	
	# Carrega e instancia nova cena
	var scene = load(path)
	var instance = scene.instantiate()
	game_root.add_child(instance)

	#Faz o fade in após o carregamento
	transition.fade_in()

# Função para tocar áudio
func play_audio(audio_path: String, volume_db: float = 0.0) -> void:
	if audio_player == null:
		push_error("AudioPlayer não está configurado!")
		return
	
	# Carrega o arquivo de áudio
	var audio_resource = load(audio_path) as AudioStream
	if audio_resource == null:
		push_error("Não foi possível carregar o áudio: " + audio_path)
		return
	
	# Configura e toca o áudio
	audio_player.stream = audio_resource
	audio_player.volume_db = volume_db
	audio_player.play()

# Função para parar o áudio atual
func stop_audio() -> void:
	if audio_player != null and audio_player.playing:
		audio_player.stop()

# Função para verificar se está tocando áudio
func is_playing_audio() -> bool:
	return audio_player != null and audio_player.playing
