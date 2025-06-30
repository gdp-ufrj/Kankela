extends Control

# Enumeração para os tipos de lupa
enum LupaType {
	DESLIGADA = 0,
	TIPO_1 = 1,
	TIPO_2 = 2
}

@export var mask_radius: float = 80.0 # Sincronizado com objeto_secreto
@onready var circulo_ref = $Referencia

# Variável para controlar o tipo atual da lupa
var current_lupa_type: LupaType = LupaType.DESLIGADA

# Referências aos diferentes sprites de lupa (será configurado na cena)
@onready var lupa_tipo_1 = $LupaTipo1
@onready var lupa_tipo_2 = $LupaTipo2

# Sinal para comunicar mudanças de tipo
signal lupa_type_changed(lupa_type: LupaType)

func _ready():
	visible = current_lupa_type != LupaType.DESLIGADA
	
	# Aplica o material do shader
	if not circulo_ref.material:
		circulo_ref.material = ShaderMaterial.new()
		circulo_ref.material.shader = load("res://Shaders/lupa_circular.gdshader")

	# Altera o tamanho para o selecionado e corrige centralidade
	var rect_size = mask_radius * 2.0
	circulo_ref.size = Vector2(rect_size, rect_size)
	circulo_ref.position = Vector2(-rect_size / 2, -rect_size / 2)
	
	# Inicializa a visibilidade dos sprites
	update_lupa_sprites()

func cycle_lupa_type():
	# Alterna entre os 3 estados (0, 1, 2)
	var next_type = (current_lupa_type + 1) % 3
	current_lupa_type = next_type as LupaType
	update_lupa_sprites()
	emit_signal("lupa_type_changed", current_lupa_type)

func turn_off_lupa():
	# Desliga imediatamente
	current_lupa_type = LupaType.DESLIGADA
	update_lupa_sprites()
	emit_signal("lupa_type_changed", current_lupa_type)

func update_lupa_sprites():
	# Atualiza a visibilidade geral da lupa
	visible = is_lupa_active()
	
	# Atualiza a visibilidade dos sprites individuais
	if lupa_tipo_1:
		lupa_tipo_1.visible = current_lupa_type == LupaType.TIPO_1
	if lupa_tipo_2:
		lupa_tipo_2.visible = current_lupa_type == LupaType.TIPO_2

func get_current_lupa_type() -> LupaType:
	return current_lupa_type

func is_lupa_active() -> bool:
	return current_lupa_type != LupaType.DESLIGADA

# Exemplo de uso seguindo o mouse
func _process(_delta: float) -> void:
	if is_lupa_active():
		var local_mouse_pos = get_global_mouse_position()
		global_position = local_mouse_pos
