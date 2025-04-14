class_name ObjetoInterativo extends CharacterBody2D

# Sinal para quando o objeto é interaction_finished
signal interaction_finished(type: InteractableType, function: Callable)

# Configurações de interação
@export var mostrar_delineado: bool = true
@export var cor_delineado: Color = Color(1, 0.8, 0, 1) # Amarelo por padrão

# Configurações do shader de delineado
@export var largura_delineado: float = 5.0
var padrao_delineado: int = 1 # 0 = padrão, 1 = círculo, 2 = quadrado
var delineado_interno: bool = false
var adicionar_margens: bool = true
@export var tamanho_spritesheet: Vector2 = Vector2(1, 1)

# Referência ao shader de delineado
var _delineado_ativo: bool = false
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

# Função customizada (opcional)
var _custom_callback: Callable

# Função que será chamada pelo player quando interact
func interact(_player: Node) -> void:
	# Método virtual para ser sobrescrito pelos objetos específicos
	print("Interagindo com ", name)
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.None, _custom_callback)

# Define uma função customizada para ser executada após a interação
func set_custom_callback(callback: Callable) -> void:
	_custom_callback = callback

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
	sprite.material.set_shader_parameter("color", cor_delineado)
	sprite.material.set_shader_parameter("width", largura_delineado)
	sprite.material.set_shader_parameter("pattern", padrao_delineado)
	sprite.material.set_shader_parameter("inside", delineado_interno)
	sprite.material.set_shader_parameter("add_margins", adicionar_margens)
	sprite.material.set_shader_parameter("number_of_images", tamanho_spritesheet)

# Desativa o delineado do objeto
func desativar_delineado() -> void:
	_delineado_ativo = false
	# Para esta versão do shader, podemos simplesmente definir largura como 0 para desativar
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("width", 0.0)

enum InteractableType {
	None,
	Dialogue,
	Item
}