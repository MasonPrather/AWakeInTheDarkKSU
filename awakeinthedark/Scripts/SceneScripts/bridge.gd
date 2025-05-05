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
var mystery_ship_examined = false

# For managing popup sequences
var popup_sequence_active = false

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
	
	# Load previously examined items from SaveManager
	load_examined_items()
	
	# Sync collected items
	restore_inventory_visuals()
	
	# Load mystery ship examined state
	mystery_ship_examined = SaveManager.get_state("bridge_examined_mystery_ship", false)

# Load previously examined items from SaveManager
func load_examined_items() -> void:
	var items_to_check = ["wheel", "charts", "spyglass", "compass", "mystery_ship", "barrel_hint"]
	for item in items_to_check:
		if SaveManager.get_state("bridge_examined_" + item, false) and not item in examined_items:
			examined_items.append(item)
	
	# Check if final note was found
	final_note_found = SaveManager.get_state("final_note_found", false)

# Play SFX
func play_click_sound(): click_sound.play()
func play_inventory_sound(): inventory_sound.play()

# Helper to wait for popup to close before proceeding
func wait_for_popup(popup, delay_after_close = 0.0):
	# Wait until popup is no longer visible
	while popup.visible:
		await get_tree().process_frame
	
	# Additional delay if specified
	if delay_after_close > 0:
		await get_tree().create_timer(delay_after_close).timeout

# Interaction Router
func handle_item_interaction(item_name: String):
	# Prevent interaction during popup sequences
	if popup_sequence_active:
		return
		
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
			popup.show_dialogue("The compass needle is spinning wildly. It's as if we're not on Earth anymore. No matter which way I turn it, the needle never settles.")
			add_to_inventory("compass")
			add_examined_item("compass")
			
		"mystery_ship":
			popup.show_dialogue("That ship in the distance... is it a mirror image of our own? I can see it clearly now - every detail matches our vessel exactly.")
			add_examined_item("mystery_ship")
			mystery_ship_examined = true
			SaveManager.set_state("bridge_examined_mystery_ship", true)
			
			# Check if player has found the final note and completed all requirements
			if final_note_found and has_all_required_items():
				# Start sequence
				popup_sequence_active = true
				
				# Wait for current popup to close
				await wait_for_popup(popup, 1.0)
				
				# Show completed message
				popup.show_dialogue("You've completed the game!")
				
				# Wait for that message to close
				await wait_for_popup(popup, 1.0)
				
				# Show ending
				show_end_game()
				
				# End sequence
				popup_sequence_active = false
			
		"barrel":
			# First check if the mystery ship has been examined
			if not has_examined("mystery_ship"):
				popup.show_dialogue("I feel like I should investigate that ship in the distance first...")
				return
				
			# Updated requirement: need all of wheel, charts, compass, AND spyglass
			if has_examined("wheel") and has_examined("charts") and has_examined("compass") and has_examined("spyglass"):
				# Check if we've already found the note
				if final_note_found:
					popup.show_dialogue("I've already found the captain's note here.")
					return
				
				# Start popup sequence
				popup_sequence_active = true
				
				# First message
				popup.show_dialogue("There's something hidden beneath this barrel... a note sealed in a bottle!")
				
				# Wait for popup to fully close
				while popup.visible:
					await get_tree().process_frame
				
				# Add a small delay
				await get_tree().create_timer(1.5).timeout
				
				# Setup note
				final_note_found = true
				SaveManager.set_state("final_note_found", true)
				final_note_item.visible = true
				add_to_inventory("final_note")
				
<<<<<<< Updated upstream
				# Show note contents
				popup.show_dialogue("'To whoever finds this: We crossed into The Void. Time and space bend here. The crew... we saw ourselves on another ship. When we made contact, they vanished. One by one, we're disappearing too. I'm the last one left. The Compass Lied. It led us here intentionally. If you're reading this, you're me, from another time. Break the cycle. -Captain'")
=======
		# Show note contents - with better text overlay
				popup.show_dialogue("'To whoever finds this: We crossed into The Void. Time and space bend here. The crew... we saw ourselves on another ship. When we made contact, they vanished. One by one, we're disappearing too. I'm the last one left. The Compass Lied. It led us here intentionally. If you're reading this, you're me, from another time. Break the cycle. -Captain'")

>>>>>>> Stashed changes
				
				# Wait for note popup to fully close
				while popup.visible:
					await get_tree().process_frame
				
				# Add a small delay
				await get_tree().create_timer(1.5).timeout
				
				# Show completion message 
				popup.show_dialogue("You've completed the game!")
				
				# Wait for completion message to fully close
				while popup.visible:
					await get_tree().process_frame
				
				# Add a small delay
				await get_tree().create_timer(1.5).timeout
				
				# Show end game screen
				show_end_game()
				
				# End sequence
				popup_sequence_active = false
			else:
				popup.show_dialogue("An empty barrel. Nothing interesting here... yet.")
				
		"final_note":
			# First check if player has examined the mystery ship
			if not has_examined("mystery_ship"):
				popup.show_dialogue("I feel like I should investigate that ship in the distance first...")
				return
<<<<<<< Updated upstream
				
			if final_note_found or SaveManager.get_state("final_note_found", false):
				# Start popup sequence
				popup_sequence_active = true
				
				# Show note contents
				final_note_item.visible = true
				popup.show_dialogue("'To whoever finds this: We crossed into The Void. Time and space bend here. The crew... we saw ourselves on another ship. When we made contact, they vanished. One by one, we're disappearing too. I'm the last one left. The Compass Lied. It led us here intentionally. If you're reading this, you're me, from another time. Break the cycle. -Captain'")
				
=======
				
			if final_note_found or SaveManager.get_state("final_note_found", false):
				# Start popup sequence
				popup_sequence_active = true
				
				# Show note contents with much shorter text and suggestion for smaller font
				final_note_item.visible = true
				
				if popup.has_method("show_dialogue_with_style"):
					# Use custom styling with smaller font
					popup.show_dialogue_with_style("'We crossed into The Void. Time bends here. Saw our own ship. Crew vanished upon contact. I'm the last one. The Compass brought us here on purpose. If you're reading this, you're me from another time. Break the cycle. -Captain'", 0.8) # 80% of normal font size
				else:
					popup.show_dialogue("'We crossed into The Void. Time bends here. Saw our own ship. Crew vanished upon contact. I'm the last one. The Compass brought us here on purpose. If you're reading this, you're me from another time. Break the cycle. -Captain'")
				
>>>>>>> Stashed changes
				# Check if we need to add it to inventory (in case player is clicking it directly)
				if not SaveManager.inventory_items.has("final_note"):
					add_to_inventory("final_note")
				
				# Wait for note popup to close
				await wait_for_popup(popup, 1.0)
				
				# Show completion message
				popup.show_dialogue("You've completed the game!")
				
				# Wait for completion message to close
				await wait_for_popup(popup, 1.0)
				
				# Show end game screen
				show_end_game()
				
				# End sequence
				popup_sequence_active = false
			else:
				popup.show_dialogue("I need to explore more of the bridge first.")
		
		"hallway_door":
			change_scene("res://Scenes/hallway_2.tscn")

# Check if all required items have been collected
func has_all_required_items() -> bool:
	var required_items = ["wheel", "charts", "spyglass", "compass", "final_note"]
	for item in required_items:
		if not SaveManager.inventory_items.has(item):
			return false
	return true

# Track examined items for puzzle progression
func add_examined_item(item: String):
	if not item in examined_items:
		examined_items.append(item)
		print("Examined " + item)
		SaveManager.set_state("bridge_examined_" + item, true)
	
	# Check if we've examined enough to hint about the barrel
	# Only show hint after a delay and after the current popup has closed
	if examined_items.size() >= 3 and not final_note_found and not "barrel_hint" in examined_items:
		examined_items.append("barrel_hint")
		SaveManager.set_state("bridge_examined_barrel_hint", true)
		
		# Find popup
		var popup = get_node("/root/Bridge/Popup")
		
		# Wait longer before showing the hint
		await get_tree().create_timer(4.0).timeout
		
		# Only show if no other popup is active
		if not popup.visible and not popup_sequence_active:
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
	# Use CanvasLayer to ensure overlay covers entire screen
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # Put it on top of everything else
	add_child(canvas_layer)
	
	# Create a full screen black overlay
	var end_screen = ColorRect.new()
	end_screen.color = Color(0, 0, 0, 0)  # Start transparent for fade
	
	# Make it cover the entire screen
	end_screen.anchor_right = 1.0
	end_screen.anchor_bottom = 1.0
	end_screen.offset_right = 0
	end_screen.offset_bottom = 0
	
	# Add to canvas layer to ensure it's on top
	canvas_layer.add_child(end_screen)
	
	# Make sure any music keeps playing through the end sequence
	for node in get_tree().get_nodes_in_group("music"):
		if node.has_method("ensure_playing"):
			node.ensure_playing()
	
	# Create a RichTextLabel for better text formatting
	var end_label = RichTextLabel.new()
	end_label.bbcode_enabled = true
	# Use larger font size with [font_size] tag
	end_label.bbcode_text = "[center][font_size=48]You understand now.[/font_size]\n\n[font_size=40]The Compass led the ship into a realm where time and space fold in on themselves. The crew didn't vanish - they became you, waking up with amnesia, exploring the empty ship.[/font_size]\n\n[font_size=40]Will you break the cycle, or are you doomed to repeat it forever?[/font_size]\n\n[font_size=60]THE END[/font_size][/center]"
	
	# Make the label much larger to fit all text
	end_label.anchor_left = 0.1
	end_label.anchor_right = 0.9
	end_label.anchor_top = 0.1
	end_label.anchor_bottom = 0.9
	
	# Set its size to use most of the screen
	end_label.offset_left = 0
	end_label.offset_right = 0
	end_label.offset_top = 0
	end_label.offset_bottom = 0
	
	# Start invisible for fade
	end_label.modulate = Color(1, 1, 1, 0)
	
	# Text settings
	end_label.fit_content = true
	end_label.scroll_active = false
	
	# Add to canvas layer
	canvas_layer.add_child(end_label)
	
	# Create button
	var button = Button.new()
	button.text = "Return to Main Menu"
	
	# Make button text larger
	var font_size = 24
	button.add_theme_font_size_override("font_size", font_size)
	
	# Center the button
	button.anchor_left = 0.5
	button.anchor_right = 0.5
	button.anchor_top = 0.8
	button.anchor_bottom = 0.8
	
	# Set its size and position
	button.offset_left = -150
	button.offset_right = 150
	button.offset_top = 0
	button.offset_bottom = 50
	
	# Hide initially
	button.visible = false
	
	# Connect button
	button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	canvas_layer.add_child(button)
	
	# Fade in animation
	var tween = create_tween()
	tween.tween_property(end_screen, "color", Color(0, 0, 0, 1), 3.0)
	tween.parallel().tween_property(end_label, "modulate", Color(1, 1, 1, 1), 5.0)
	
	# Show button after delay
	await get_tree().create_timer(6.0).timeout
	button.visible = true
	
	# Mark game as completed
	SaveManager.set_state("game_completed", true)
	SaveManager.save_game()

func _on_return_button_pressed():
	# Return to main menu
	change_scene("res://Scenes/main_menu.tscn")
