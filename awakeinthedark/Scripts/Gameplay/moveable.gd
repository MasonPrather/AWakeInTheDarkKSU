extends Area2D

signal RevealItem

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		position.x += 400  # Move 200 pixels to the right
		emit_signal("RevealItem")
		print("Revealing...")
