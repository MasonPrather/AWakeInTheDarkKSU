extends Node2D

@onready var click_sound = $ClickSoundPlayer
@onready var inventory_sound = $InventorySoundPlayer

# Track what has been examined
var examined_items = []
var final_note_found = false

func _ready() -> void:
	# Hide all item sprites initially
	$WheelCloseup.visible = false
	$SpyglassCloseup.visible = false
	$ChartsCloseup.visible = false
	$CompassCloseup.visible = false
	$FinalNoteItem.visible = false
	
	# Load SFX
	click_sound.stream = load("res://Audio/sfx/rclick-13693.mp3")
	inventory_sound.stream = load("res://Audio/sfx/item-equip-6904.mp3")

# Play SFX
func play_click_sound(): click_sound.play()

# Handle item interactions
func handle_item_interaction(item_name):
	var dialogue_popup = get_node("/root/Bridge/Popup")
	
	match item_name:
		"wheel":
			$WheelCloseup.visible = true
			dialogue_popup.show_dialogue("The wheel is locked in place... someone tied it with a strange knot.")
			add_examined_item("wheel")
			
		"charts":
			$ChartsCloseup.visible = true
			dialogue_popup.show_dialogue("These navigation charts show we've gone far off course. There are strange markings near a location marked 'The Void'.")
			add_examined_item("charts")
			
		"spyglass":
			$SpyglassCloseup.visible = true
			dialogue_popup.show_dialogue("Through the spyglass, I can see another ship in the distance. It looks... identical to this one?")
			add_examined_item("spyglass")
			
		"compass":
			$CompassCloseup.visible = true
			dialogue_popup.show_dialogue("The compass needle is spinning wildly. It's as if we're not on Earth anymore.")
			add_examined_item("compass")
			
		"mysterious_ship":
			dialogue_popup.show_dialogue("That ship in the distance... is it a mirror image of our own?")
			add_examined_item("mysterious_ship")
			
		"barrel":
			if has_examined("wheel") and has_examined("charts") and has_examined("compass"):
				dialogue_popup.show_dialogue("There's something hidden beneath this barrel... a note sealed in a bottle!")
				# Unlock the final note
				final_note_found = true
			else:
				dialogue_popup.show_dialogue("An empty barrel. Nothing interesting here... yet.")
				
		"final_note":
			if final_note_found:
				$FinalNoteItem.visible = true
				dialogue_popup.show_dialogue("'To whoever finds this: We crossed into The Void. Time and space bend here. The crew... we saw ourselves on another ship. When we made contact, they vanished. One by one, we're disappearing too. I'm the last one left. The Compass Lied. It led us here intentionally. If you're reading this, you're me, from another time. Break the cycle. -Captain'")
				await get_tree().create_timer(15.0).timeout  # Give player time to read
				show_end_game()
			else:
				dialogue_popup.show_dialogue("I need to explore more of the bridge first.")

func add_examined_item(item):
	if not item in examined_items:
		examined_items.append(item)
		print("Examined " + item)
	
	# Check if we've examined enough to hint about the barrel
	if examined_items.size() >= 3 and not final_note_found and not "barrel_hint" in examined_items:
		examined_items.append("barrel_hint")
		var dialogue_popup = get_node("/root/Bridge/Popup")
		await get_tree().create_timer(2.0).timeout
		dialogue_popup.show_dialogue("Something feels off about this bridge. I should check everything carefully...")

func has_examined(item):
	return item in examined_items

func show_end_game():
	# Create end game screen
	var end_screen = ColorRect.new()
	end_screen.color = Color(0, 0, 0, 0)
	end_screen.size = Vector2(1920, 1080)  # Adjust to your resolution
	add_child(end_screen)
	
	var end_label = Label.new()
	end_label.text = "You understand now. The Compass led the ship into a realm where time and space fold in on themselves. The crew didn't vanish - they became you, waking up with amnesia, exploring the empty ship.\n\nWill you break the cycle, or are you doomed to repeat it forever?\n\nTHE END"
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_label.size = Vector2(800, 400)
	end_label.position = Vector2(560, 340)  # Center in a 1920x1080 screen
	end_label.modulate = Color(1, 1, 1, 0)
	end_screen.add_child(end_label)
	
	# Fade in animation
	var tween = create_tween()
	tween.tween_property(end_screen, "color", Color(0, 0, 0, 1), 3.0)
	tween.parallel().tween_property(end_label, "modulate", Color(1, 1, 1, 1), 5.0)
	
	# Add a "Return to Main Menu" button (optional)
	await get_tree().create_timer(8.0).timeout
	var button = Button.new()
	button.text = "Return to Main Menu"
	button.position = Vector2(810, 600)
	button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	end_screen.add_child(button)

func _on_return_button_pressed():
	# Return to main menu or restart
	get_tree().change_scene_to_file("res://awakeinthedark/Scenes/main_menu.tscn")
	# Or reload the first scene: get_tree().change_scene_to_file("res://awakeinthedark/Scenes/captains_cabin.tscn")
