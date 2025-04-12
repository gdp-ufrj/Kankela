class_name ObjetoInterativo extends CharacterBody2D

# Sinal para quando o objeto é interaction_finished
signal interaction_finished(type: InteractableType)

# Função que será chamada pelo player quando interact
func interact(_player: Node) -> void:
	# Método virtual para ser sobrescrito pelos objetos específicos
	print("Interagindo com ", name)
	
	# Emite o sinal de interação
	interaction_finished.emit()

enum InteractableType {
	None,
	Dialogue,
	Item
}