extends Node2D

# References to sound players
@onready var click_sound = $ClickSoundPlayer
@onready var inventory_sound = $InventorySoundPlayer

func _ready() -> void:
	# Hide all item sprites initially
	$MapItem.visible = false
	$CompassItem.visible = false
	$NoteItem.visible = false
	$KeyItem.visible = false
	$LogbookItem.visible = false

	# Set up sound effects
	click_sound.stream = load("res://Audio/sfx/rclick-13693.mp3")
	inventory_sound.stream = load("res://Audio/sfx/item-equip-6904.mp3")

# Play sounds
func play_click_sound():
	click_sound.play()

func play_inventory_sound():
	inventory_sound.play()

# Handle item interactions
func handle_item_interaction(item_name):
	play_click_sound()

	var dialogue_popup = get_node("/root/CaptainsCabin/Popup")
	match item_name:
		"logbook":
			$LogbookItem.visible = true
			dialogue_popup.show_dialogue("You found the logbook with strange entries...")
			add_to_inventory("logbook")

		"coffee_cup":
			dialogue_popup.show_dialogue("A half-finished cup of coffee. Still warm...")

		"map":
			$MapItem.visible = true
			dialogue_popup.show_dialogue("An old map that might reveal the ship's location...")
			add_to_inventory("map")

		"compass":
			$CompassItem.visible = true
			dialogue_popup.show_dialogue("The ship's compass... it appears to be broken.")
			add_to_inventory("compass")

		"note":
			$NoteItem.visible = true
			dialogue_popup.show_dialogue("A note that reads 'The Compass Lied'...")
			add_to_inventory("compass_note")

		"door":
			if has_item("key"):
				dialogue_popup.show_dialogue("You unlocked the door!")
				await get_tree().create_timer(2.0).timeout

				SaveManager.current_scene_path = "res://Scenes/hallway_1.tscn"
				SaveManager.save_game()
				get_tree().change_scene_to_file("res://Scenes/hallway_1.tscn")
			else:
				dialogue_popup.show_dialogue("It's locked! There must be a key somewhere...")

		"key":
			if has_item("logbook") and has_item("map") and has_item("compass") and has_item("compass_note"):
				$KeyItem.visible = true
				dialogue_popup.show_dialogue("You found a key! It might open the door.")
				add_to_inventory("key")
			else:
				dialogue_popup.show_dialogue("I need to find out what's going on - I can't look at anything else until I do.")

# Use SaveManager for inventory persistence
func add_to_inventory(item):
	if not SaveManager.inventory_items.has(item):
		SaveManager.add_to_inventory(item)
		play_inventory_sound()
		print("Added %s to global inventory" % item)

func has_item(item):
	return SaveManager.inventory_items.has(item)
