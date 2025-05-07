class_name Item extends Resource

# Identificador único do item
@export var id: String = ""
# Nome do item que será exibido na interface
@export var nome: String = "Item"
# Descrição do item
@export var descricao: String = "Um item comum"
# Ícone do item que será exibido no inventário
@export var icone: Texture2D
# Indica se o item já foi usado em alguma missão
@export var usado: bool = false
# Indica se o item foi coletado pelo jogador
@export var coletado: bool = false
# Associação com missões (IDs das missões que precisam deste item)
@export var missoes_relacionadas: Array[String] = []

func usar() -> void:
    usado = true
    
func coletar() -> void:
    coletado = true
    
func esta_disponivel() -> bool:
    return coletado and not usado