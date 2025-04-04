extends Area2D

@export var item_name: String = "name"

func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(item_name + " was clicked!")
		if get_parent().has_method("handle_item_interaction"):
			get_parent().handle_item_interaction(item_name)
