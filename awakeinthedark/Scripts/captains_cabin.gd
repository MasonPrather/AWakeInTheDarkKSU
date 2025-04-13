extends Node2D

# Signals
signal item_collected(item_name)
signal reveal_item(item_name)

# State tracking
var collected_items = []
var door_unlocked = false

# Pause menu
var is_paused = false

func _ready():
	print("Captain's cabin scene loaded")
	
	# Create placeholder silent audio for all audio players
	_setup_placeholder_audio()
	
	# Initially hide all inventory items if they exist
	if has_node("MapItem"):
		$MapItem.visible = false
	if has_node("CompassItem"):
		$CompassItem.visible = false
	if has_node("NoteItem"):
		$NoteItem.visible = false
	if has_node("LogbookItem"):
		$LogbookItem.visible = false
	if has_node("KeyItem"):
		$KeyItem.visible = false
	
	# Connect signals
	if self.has_signal("item_collected"):
		connect("item_collected", Callable(self, "_on_item_collected"))
	
	# Load game state
	load_game_state()
	
	
	print("Captain's cabin initialization complete")

func _setup_placeholder_audio():
	# Create silent audio stream
	var create_silent_audio = func():
		var audio = AudioStreamWAV.new()
		audio.format = AudioStreamWAV.FORMAT_8_BITS
		audio.stereo = false
		audio.data = PackedByteArray([128, 128, 128, 128, 128, 128, 128, 128])
		return audio
	
	# Apply to all audio players
	if has_node("BackgroundMusic"):
		$BackgroundMusic.stream = create_silent_audio.call()
		
	if has_node("ClickSoundPlayer"):
		$ClickSoundPlayer.stream = create_silent_audio.call()
		
	if has_node("InventorySoundPlayer"):
		$InventorySoundPlayer.stream = create_silent_audio.call()



func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_pause()

# Create a built-in pause menu instead of relying on an external script
func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	
	# If already paused, just unpause
	if !is_paused:
		if has_node("PauseMenu"):
			get_node("PauseMenu").queue_free()
		return
	
	# Create pause menu
	var pause_menu = CanvasLayer.new()
	pause_menu.name = "PauseMenu"
	pause_menu.layer = 10
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_menu)
	
	# Add panel
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(400, 300)
	panel.position = Vector2(-200, -150)
	panel.self_modulate = Color(0.1, 0.1, 0.1, 0.9)
	pause_menu.add_child(panel)
	
	# Add title
	var title = Label.new()
	title.text = "GAME PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.position = Vector2(0, 20)
	title.size = Vector2(400, 30)
	panel.add_child(title)
	
	# Add buttons container
	var container = VBoxContainer.new()
	container.position = Vector2(50, 70)
	container.size = Vector2(300, 200)
	container.add_theme_constant_override("separation", 10)
	panel.add_child(container)
	
	# Add buttons
	var resume = Button.new()
	resume.text = "Resume Game"
	resume.add_theme_font_size_override("font_size", 18)
	resume.pressed.connect(toggle_pause)
	container.add_child(resume)
	
	var save = Button.new()
	save.text = "Save Game"
	save.add_theme_font_size_override("font_size", 18)
	save.pressed.connect(_on_save_pressed)
	container.add_child(save)
	
	var main_menu = Button.new()
	main_menu.text = "Return to Main Menu"
	main_menu.add_theme_font_size_override("font_size", 18)
	main_menu.pressed.connect(_on_main_menu_pressed)
	container.add_child(main_menu)
	
	# Set focus to resume button
	resume.grab_focus()

func _on_save_pressed():
	if has_node("/root/SaveManager"):
		var save_manager = get_node("/root/SaveManager")
		save_manager.save_game()
		
		# Show save confirmation
		var panel = get_node("PauseMenu").get_child(0)
		var confirm = Label.new()
		confirm.text = "Game Saved!"
		confirm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		confirm.add_theme_font_size_override("font_size", 16)
		confirm.position = Vector2(0, 270)
		confirm.size = Vector2(400, 20)
		panel.add_child(confirm)
		
		# Remove confirmation after delay
		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(confirm):
			confirm.queue_free()

func _on_load_pressed():
	toggle_pause()  # Unpause game
	
	if has_node("/root/SaveManager"):
		var save_manager = get_node("/root/SaveManager")
		save_manager.load_game()

func _on_main_menu_pressed():
	toggle_pause()  # Unpause game
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Load saved state for this scene
func load_game_state():
	if has_node("/root/SaveManager"):
		# Load collected items from SaveManager
		collected_items = get_node("/root/SaveManager").inventory_items.duplicate()
		
		# Update items visibility based on saved state
		for item in collected_items:
			update_item_visibility(item, true)
			
		# Load door state
		door_unlocked = get_node("/root/SaveManager").get_state("door_unlocked", false)

# Save state for this scene
func save_game_state():
	if has_node("/root/SaveManager"):
		# Door state is saved directly in SaveManager
		get_node("/root/SaveManager").set_state("door_unlocked", door_unlocked)
		
		# Manual save
		get_node("/root/SaveManager").save_game()

# Handle interactions with items in the scene
func handle_item_interaction(item_name):
	if has_node("ClickSoundPlayer"):
		$ClickSoundPlayer.play()
	
	match item_name:
		"map":
			if has_node("Popup"):
				$Popup.show_dialogue("An old, weathered map. It seems to show a route through dangerous waters.")
			if not "map" in collected_items:
				emit_signal("item_collected", "map")
				
		"compass":
			if has_node("Popup"):
				$Popup.show_dialogue("A broken compass. Strange... it doesn't point north.")
			if not "compass" in collected_items:
				emit_signal("item_collected", "compass")
				
		"note":
			if has_node("Popup"):
				$Popup.show_dialogue("A hastily written note. It reads: 'The compass lies. Trust only the stars.'")
			if not "note" in collected_items:
				emit_signal("item_collected", "note")
				
		"logbook":
			if has_node("Popup"):
				$Popup.show_dialogue("The captain's logbook. It contains strange entries about encounters with unknown creatures.")
			if not "logbook" in collected_items:
				emit_signal("item_collected", "logbook")
				
		"key":
			if has_node("Popup"):
				$Popup.show_dialogue("A small brass key. It might unlock something important.")
			if not "key" in collected_items:
				emit_signal("item_collected", "key")
				
		"coffee_cup":
			if has_node("Popup"):
				$Popup.show_dialogue("The captain's coffee cup. It's still warm...")
			
		"door":
			if "key" in collected_items and not door_unlocked:
				if has_node("Popup"):
					$Popup.show_dialogue("You unlock the door with the key.")
				door_unlocked = true
				if has_node("/root/SaveManager"):
					get_node("/root/SaveManager").set_state("door_unlocked", true)
				await get_tree().create_timer(2.0).timeout
				get_tree().change_scene_to_file("res://Scenes/hallway.tscn")
			elif door_unlocked:
				if has_node("Popup"):
					$Popup.show_dialogue("The door is unlocked. You can proceed to the hallway.")
				await get_tree().create_timer(2.0).timeout
				get_tree().change_scene_to_file("res://Scenes/hallway.tscn")
			else:
				if has_node("Popup"):
					$Popup.show_dialogue("The door is locked. You need to find a key.")

func _on_item_collected(item_name):
	if not item_name in collected_items:
		collected_items.append(item_name)
		if has_node("InventorySoundPlayer"):
			$InventorySoundPlayer.play()
		update_item_visibility(item_name, true)
		
		if has_node("/root/SaveManager"):
			get_node("/root/SaveManager").add_to_inventory(item_name)
		
		save_game_state()  #write save immediately after collecting

# Update the visibility of an item in the inventory bar
func update_item_visibility(item_name, is_visible):
	match item_name:
		"map":
			if has_node("MapItem"):
				$MapItem.visible = is_visible
		"compass":
			if has_node("CompassItem"):
				$CompassItem.visible = is_visible
		"note":
			if has_node("NoteItem"):
				$NoteItem.visible = is_visible
		"logbook":
			if has_node("LogbookItem"):
				$LogbookItem.visible = is_visible
		"key":
			if has_node("KeyItem"):
				$KeyItem.visible = is_visible
