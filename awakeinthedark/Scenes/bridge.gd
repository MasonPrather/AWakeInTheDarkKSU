extends Node2D

@onready var click_sound = $ClickSoundPlayer
@onready var inventory_sound = $InventorySoundPlayer
@onready var wheel_item = $WheelItem
@onready var charts_item = $ChartsItem
@onready var spyglass_item = $SpyglassItem 
@onready var compass_item = $CompassItem
@onready var final_note_item = $FinalNoteItem

# Track examined items for puzzle progression
var examined_items = []
var final_note_found = false

func _ready() -> void:
	# Hide all item visuals initially
	wheel_item.visible = false
	charts_item.visible = false
	spyglass_item.visible = false
	compass_item.visible = false
	final_note_item.visible = false
	
	# Load SFX
	click_sound.stream = load("res://Audio/sfx/rclick-13693.mp3")
	inventory_sound.stream = load("res://Audio/sfx/item-equip-6904.mp3")
	
	# Sync collected items
	restore_inventory_visuals()

# Play SFX
func play_click_sound(): click_sound.play()
func play_inventory_sound(): inventory_sound.play()

# Interaction Router
func handle_item_interaction(item_name: String):
	play_click_sound()
	var popup = get_node("/root/Bridge/Popup")
	
	match item_name:
		"wheel":
			wheel_item.visible = true
			popup.show_dialogue("The wheel is locked in place... someone tied it with a strange knot.")
			add_to_inventory("wheel")
			add_examined_item("wheel")
			
		"charts":
			charts_item.visible = true
			popup.show_dialogue("These navigation charts show we've gone far off course. There are strange markings near a location marked 'The Void'.")
			add_to_inventory("charts")
			add_examined_item("charts")
			
		"spyglass":
			spyglass_item.visible = true
			popup.show_dialogue("Through the spyglass, I can see another ship in the distance. It looks... identical to this one?")
			add_to_inventory("spyglass")
			add_examined_item("spyglass")
			
		"compass":
			compass_item.visible = true
			popup.show_dialogue("The compass needle is spinning wildly. It's as if we're not on Earth anymore.")
			add_to_inventory("compass")
			add_examined_item("compass")
			
		"mysterious_ship":
			popup.show_dialogue("That ship in the distance... is it a mirror image of our own?")
			add_examined_item("mystery_ship")
			
		"barrel":
			if has_examined("wheel") and has_examined("charts") and has_examined("compass"):
				popup.show_dialogue("There's something hidden beneath this barrel... a note sealed in a bottle!")
				final_note_found = true
				SaveManager.set_state("final_note_found", true)
			else:
				popup.show_dialogue("An empty barrel. Nothing interesting here... yet.")
				
		"final_note":
			if final_note_found or SaveManager.get_state("final_note_found", false):
				final_note_item.visible = true
				popup.show_dialogue("'To whoever finds this: We crossed into The Void. Time and space bend here. The crew... we saw ourselves on another ship. When we made contact, they vanished. One by one, we're disappearing too. I'm the last one left. The Compass Lied. It led us here intentionally. If you're reading this, you're me, from another time. Break the cycle. -Captain'")
				add_to_inventory("final_note")
				# Wait before showing end screen
				await get_tree().create_timer(12.0).timeout
				show_end_game()
			else:
				popup.show_dialogue("I need to explore more of the bridge first.")
		
		"hallway_door":
			change_scene("res://Scenes/hallway_2.tscn")

# Track examined items for puzzle progression
func add_examined_item(item: String):
	if not item in examined_items:
		examined_items.append(item)
		print("Examined " + item)
		SaveManager.set_state("bridge_examined_" + item, true)
	
	# Check if we've examined enough to hint about the barrel
	if examined_items.size() >= 3 and not final_note_found and not "barrel_hint" in examined_items:
		examined_items.append("barrel_hint")
		var popup = get_node("/root/Bridge/Popup")
		await get_tree().create_timer(2.0).timeout
		popup.show_dialogue("Something feels off about this bridge. I should check everything carefully...")

func has_examined(item: String) -> bool:
	return item in examined_items or SaveManager.get_state("bridge_examined_" + item, false)

# Global Inventory (via SaveManager)
func add_to_inventory(item: String):
	if not SaveManager.inventory_items.has(item):
		SaveManager.add_to_inventory(item)
		play_inventory_sound()
		print("Added %s to global inventory" % item)

func restore_inventory_visuals():
	for item in SaveManager.inventory_items:
		match item:
			"wheel":
				wheel_item.visible = true
			"charts":
				charts_item.visible = true
			"spyglass":
				spyglass_item.visible = true
			"compass":
				compass_item.visible = true
			"final_note":
				final_note_item.visible = true
	
	# Check if final note was found
	final_note_found = SaveManager.get_state("final_note_found", false)

func change_scene(path: String):
	SaveManager.current_scene_path = path
	SaveManager.save_game()
	get_tree().change_scene_to_file(path)

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
	
	# Add a "Return to Main Menu" button
	await get_tree().create_timer(8.0).timeout
	var button = Button.new()
	button.text = "Return to Main Menu"
	button.position = Vector2(810, 600)
	button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	end_screen.add_child(button)
	
	# Mark game as completed
	SaveManager.set_state("game_completed", true)
	SaveManager.save_game()

func _on_return_button_pressed():
	# Return to main menu
	change_scene("res://Scenes/main_menu.tscn")
