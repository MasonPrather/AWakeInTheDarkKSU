extends Node2D

func _ready() -> void:
	# hide all item sprites initially
	$MapItem.visible = false
	$CompassItem.visible = false
	$NoteItem.visible = false
	$KeyItem.visible = false

# handle item interactions from the clickable areas
func handle_item_interaction(item_name):
	match item_name:
		"logbook":
			$LogbookItem.visible = true
			print("You found the logbook with strange entries...")
			
		"coffee_cup":
			$CoffeeCupItem.visible = true
			print("A half-finished cup of coffee. Still warm...")
			
		"map":
			$MapItem.visible = true
			print("An old map that might reveal the ship's location...")
			
		"compass":
			$CompassItem.visible = true
			print("The ship's compass... it appears to be broken.")
			
		"compass_note":
			$CompassNoteItem.visible = true
			print("A note that reads 'The Compass Lied'...")
			
		"key":
			$KeyItem.visible = true
			print("You found a key! It might open the door.")
			add_to_inventory("key")

# simple inventory system
var inventory = []

func add_to_inventory(item):
	if not item in inventory:
		inventory.append(item)
		print("Added " + item + " to inventory")

func has_item(item):
	return item in inventory
