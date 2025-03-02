extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_item_clicked(item_name):
	match item_name:
		"logbook":
			$LogbookItem.visible = true
		"coffee_cup":
			$CoffeeCupItem.visible = true
		"map":
			$MapItem.visible = true
		"compass":
			$CompassItem.visible = true
		"compass_note":
			$CompassNoteItem.visible = true
		"key":
			$KeyItem.visible = true
			# Update player progress
