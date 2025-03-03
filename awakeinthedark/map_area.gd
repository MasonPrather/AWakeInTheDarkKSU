extends Area2D

var item_name = "map"

func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(item_name + " was clicked!")
		# Call your interaction function here
		get_parent().handle_item_interaction(item_name)
