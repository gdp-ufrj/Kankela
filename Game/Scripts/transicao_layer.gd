extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)  # 0.5 segundos para fade

func fade_in():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5)  # 0.5 segundos para fade
