class_name ObjetoColetavel extends "res://Scripts/ObjetoInterativo.gd"

# Texto exibido ao interagir com este objeto
@export var texto_interacao: String = "Você coletou um item!"
var hasInteracted: bool = false

func interact(_player: Node) -> void:
	if hasInteracted: return

	hasInteracted = true
	# Exibe mensagem no console
	print(texto_interacao)
	
	# Emite o sinal de interação
	interaction_finished.emit(InteractableType.Item)
	
	# Efeito visual de coleta (pode adicionar partículas ou animação)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.5)
	self.interaction_finished.disconnect(_player._on_objeto_interaction_finished)
	tween.tween_callback(self.queue_free)
