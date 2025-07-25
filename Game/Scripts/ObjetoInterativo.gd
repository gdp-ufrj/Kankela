@tool
class_name ObjetoInterativo extends CollisionObject2D

# Sinal para quando o objeto é interaction_finished
signal interaction_finished(type: InteractableType, function: Callable)

# Configurações de interação
@export var mostrar_delineado: bool = true
@export var cor_delineado: Color = Color(1, 0.8, 0, 1) # Amarelo por padrão

# Referência ao shader de delineado
var _delineado_ativo: bool = false

# Exportando sprite
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
var sprite_texture: Texture2D:
	set(nova_textura):
		sprite_texture = nova_textura
		_update_sprite_texture()

# Exportando área de colisão do objeto
var CollisionShape: CollisionShape2D
var FormaColisao: Shape2D
var PosicaoColisao: Vector2

func _ready() -> void:
	_update_sprite_texture()

	if not Engine.is_editor_hint():
		var player = %Player
		self.interaction_finished.connect(player._on_objeto_interaction_finished)
		
		# Definindo a área de colisão
		if CollisionShape and FormaColisao:
			CollisionShape.shape = FormaColisao
			CollisionShape.position = PosicaoColisao

func _update_sprite_texture():
	# Verificamos se o nó já está na árvore de cena e se o filho "Sprite2D" existe.
	if is_inside_tree() and has_node("Sprite2D"):
		var sprite_node = get_node("Sprite2D")
		if sprite_texture: sprite_node.texture = sprite_texture
		
		# Força o editor a redesenhar. Às vezes é necessário.
		if sprite_node:
			sprite_node.update_configuration_warnings()

# Função que será chamada pelo player quando interact
func interact(_player: Node) -> void:
	# Método virtual para ser sobrescrito pelos objetos específicos
	print("Interagindo com ", name)
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.None)


# Ativa o delineado do objeto
func ativar_delineado() -> void:
	if not mostrar_delineado or not sprite:
		return
		
	_delineado_ativo = true
	
	# Verificar se o shader material já existe
	if not sprite.material:
		var shader_material = ShaderMaterial.new()
		var shader: Shader = load("res://Shaders/delineado.gdshader")
		if not shader:
			push_error("Shader de delineado não encontrado!")
			return
		
		shader_material.shader = shader
		sprite.material = shader_material
	
	# Configurar o delineado com os novos parâmetros do shader
	sprite.material.set_shader_parameter("outline_color", cor_delineado)
	sprite.material.set_shader_parameter("shade_color", Color(0, 0, 0, 0))

# Desativa o delineado do objeto
func desativar_delineado() -> void:
	_delineado_ativo = false
	# Para esta versão do shader, podemos simplesmente definir largura como 0 para desativar
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("outline_color", Color(0, 0, 0, 0))

enum InteractableType {
	None,
	Dialogue,
	Item,
	Door,
	Lamp,
	Clues
}
