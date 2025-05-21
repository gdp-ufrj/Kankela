class_name Quest extends Resource

# Identificador único da missão
@export var id: String = ""
# Título da missão
@export var titulo: String = "Nova Missão"
# Descrição da missão
@export var descricao: String = "Descrição da missão"
# Estado da missão
enum EstadoMissao {NAO_INICIADA, EM_ANDAMENTO, COMPLETA}
@export var estado: EstadoMissao = EstadoMissao.NAO_INICIADA
# IDs dos itens necessários para completar a missão
@export var itens_necessarios: Array[String] = []
# ID da próxima missão que será desbloqueada ao concluir esta
@export var proxima_missao: String = ""
# Diálogos específicos associados com esta missão
@export_file("*.dialogue") var arquivo_dialogo_completo: String
@export var titulo_dialogo_completo: String = ""

func iniciar() -> void:
	estado = EstadoMissao.EM_ANDAMENTO
	
func completar() -> void:
	estado = EstadoMissao.COMPLETA

	
func is_nao_iniciada() -> bool:
	return estado == EstadoMissao.NAO_INICIADA

func is_em_andamento() -> bool:
	return estado == EstadoMissao.EM_ANDAMENTO
	
func is_completa() -> bool:
	return estado == EstadoMissao.COMPLETA
