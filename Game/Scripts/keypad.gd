extends Control

@onready var label = $VBoxContainer/MarginContainer/Label

@export var senha = '666'
@export var tamanho = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func keyPressed(num):
	if (str(num) == 'c'):
		label.text = ''
	elif (str(num) == 'ok'):
		if label.text == senha:
			label.text = 'ACEITO'
	elif (len(label.text) < tamanho):
		label.text += str(num)


func _on_button_1_pressed() -> void:
	keyPressed(1)


func _on_button_2_pressed() -> void:
	keyPressed(2)


func _on_button_3_pressed() -> void:
	keyPressed(3)


func _on_button_4_pressed() -> void:
	keyPressed(4)


func _on_button_5_pressed() -> void:
	keyPressed(5)


func _on_button_6_pressed() -> void:
	keyPressed(6)


func _on_button_7_pressed() -> void:
	keyPressed(7)


func _on_button_8_pressed() -> void:
	keyPressed(8)


func _on_button_9_pressed() -> void:
	keyPressed(9)


func _on_button_c_pressed() -> void:
	keyPressed('c')


func _on_button_0_pressed() -> void:
	keyPressed(0)


func _on_button_ok_pressed() -> void:
	keyPressed('ok')
