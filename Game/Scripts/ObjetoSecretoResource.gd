@tool
class_name ObjetoSecretoResource extends Resource

# Enumeração para os tipos de lupa (deve ser igual ao da ObjetoSecreto.gd)
enum LupaType {
	DESLIGADA = 0,
	TIPO_1 = 1,
	TIPO_2 = 2
}

@export var required_lupa_type: LupaType = LupaType.TIPO_1
@export var sprite_texture: Texture2D
@export var position: Vector2 = Vector2.ZERO
@export var scale: Vector2 = Vector2(1, 1)
