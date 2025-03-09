extends Node2D

func _ready() -> void:
	# hide all item sprites initially
	$MapItem.visible = false
	$CompassItem.visible = false
	$NoteItem.visible = false
	$KeyItem.visible = false
	$LogbookItem.visible = false


# handle item interactions from the clickable areas
func handle_item_interaction(item_name):
	var dialogue_popup = get_node("/root/CaptainsCabin/Popup")
	match item_name:
		"logbook":
			$LogbookItem.visible = true
			print("You found the logbook with strange entries...")
			dialogue_popup.show_dialogue("You found the logbook with strange entries...")
			add_to_inventory("logbook")
			
		"coffee_cup":
			$CoffeeCupItem.visible = true
			print("A half-finished cup of coffee. Still warm...")
			dialogue_popup.show_dialogue("A half-finished cup of coffee. Still warm...")
			
		"map":
			$MapItem.visible = true
			print("An old map that might reveal the ship's location...")
			dialogue_popup.show_dialogue("An old map that might reveal the ship's location...")
			add_to_inventory("map")
			
		"compass":
			$CompassItem.visible = true
			print("The ship's compass... it appears to be broken.")
			dialogue_popup.show_dialogue("The ship's compass... it appears to be broken.")
			add_to_inventory("compass")
			
			
		"compass_note":
			$CompassNoteItem.visible = true
			print("A note that reads 'The Compass Lied'...")
			dialogue_popup.show_dialogue("A note that reads 'The Compass Lied'...")
			add_to_inventory("compass_note")
			
			
		"key":
			$KeyItem.visible = true
			print("You found a key! It might open the door.")
			add_to_inventory("key")
			dialogue_popup.show_dialogue("You found a key! It might open the door.")

# simple inventory system
var inventory = []

func add_to_inventory(item):
	if not item in inventory:
		inventory.append(item)
		print("Added " + item + " to inventory")

func has_item(item):
	return item in inventory
