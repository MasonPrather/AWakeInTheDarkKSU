extends Node2D

# References to sound players
@onready var click_sound = $ClickSoundPlayer
@onready var inventory_sound = $InventorySoundPlayer

func _ready() -> void:
	# hide all item sprites initially
	$MapItem.visible = false
	$CompassItem.visible = false
	$NoteItem.visible = false
	$KeyItem.visible = false
	$LogbookItem.visible = false
	
	# Set up sound effects
	click_sound.stream = load("res://Audio/sfx/rclick-13693.mp3")
	inventory_sound.stream = load("res://Audio/sfx/item-equip-6904.mp3")

# Function to play the click sound
func play_click_sound():
	click_sound.play()

# Function to play the inventory sound
func play_inventory_sound():
	inventory_sound.play()

# handle item interactions from the clickable areas
func handle_item_interaction(item_name):
	# Play click sound for any interaction
	play_click_sound()
	
	var dialogue_popup = get_node("/root/CaptainsCabin/Popup")
	match item_name:
		"logbook":
			$LogbookItem.visible = true
			print("You found the logbook with strange entries...")
			dialogue_popup.show_dialogue("You found the logbook with strange entries...")
			add_to_inventory("logbook")
			
		"coffee_cup":
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
			
		"note":
			$NoteItem.visible = true
			print("A note that reads 'The Compass Lied'...")
			dialogue_popup.show_dialogue("A note that reads 'The Compass Lied'...")
			add_to_inventory("compass_note")
			
		"door":
			if has_item("key"):
				print("You unlocked the door!")
				dialogue_popup.show_dialogue("You unlocked the door!")
				# Here you would add code to transition to the next room
				# Example: get_tree().change_scene_to_file("res://Scenes/hallway.tscn")
			else:
				print("It's locked! There must be a key somewhere...")
				dialogue_popup.show_dialogue("It's locked! There must be a key somewhere...")
			
		"key":
			# Check if player has found all other important items
			if has_item("logbook") and has_item("map") and has_item("compass") and has_item("compass_note"):
				$KeyItem.visible = true
				print("You found a key! It might open the door.")
				dialogue_popup.show_dialogue("You found a key! It might open the door.")
				add_to_inventory("key")
			else:
				print("I need to find out what's going on - I can't look at anything else until I do.")
				dialogue_popup.show_dialogue("I need to find out what's going on - I can't look at anything else until I do.")

# simple inventory system
var inventory = []
func add_to_inventory(item):
	if not item in inventory:
		inventory.append(item)
		print("Added " + item + " to inventory")
		play_inventory_sound()
		
func has_item(item):
	return item in inventory
