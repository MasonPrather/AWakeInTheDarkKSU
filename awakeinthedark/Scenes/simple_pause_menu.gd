extends Node2D

# Node references
var pause_panel: Panel
var menu_container: VBoxContainer
var resume_button: Button
var save_button: Button
var main_menu_button: Button

var is_paused = false

func _ready():
	# Create the pause menu programmatically
	create_pause_menu()
	# Hide it initially
	pause_panel.visible = false
	
	# Set the correct process mode to allow pausing
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC key by default
		toggle_pause()

func create_pause_menu():
	# Create background panel
	pause_panel = Panel.new()
	pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_panel.size = Vector2(400, 300)
	pause_panel.position = Vector2(-200, -150) # Offset from center
	pause_panel.self_modulate = Color(0.1, 0.1, 0.1, 0.9) # Dark semi-transparent panel
	add_child(pause_panel)
	
	# Create title
	var title = Label.new()
	title.text = "GAME PAUSED"

	title.add_theme_font_size_override("font_size", 24)
	title.position = Vector2(0, 20)
	title.size = Vector2(400, 30)
	pause_panel.add_child(title)
	
	# Create VBox container for buttons
	menu_container = VBoxContainer.new()
	menu_container.position = Vector2(50, 70)
	menu_container.size = Vector2(300, 200)
	menu_container.add_theme_constant_override("separation", 10)
	pause_panel.add_child(menu_container)
	
	# Create buttons
	resume_button = create_button("Resume Game", "_on_resume_pressed")
	save_button = create_button("Save Game", "_on_save_pressed")
	main_menu_button = create_button("Return to Main Menu", "_on_main_menu_pressed")
	
	# Add buttons to container
	menu_container.add_child(resume_button)
	menu_container.add_child(save_button)
	menu_container.add_child(main_menu_button)

func create_button(text, callback_method):
	var button = Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", 18)
	button.connect("pressed", Callable(self, callback_method))
	return button

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_panel.visible = is_paused
	
	if is_paused:
		resume_button.grab_focus()

func _on_resume_pressed():
	toggle_pause()

func _on_save_pressed():
	if has_node("/root/SaveManager"):
		var save_manager = get_node("/root/SaveManager")
		save_manager.current_scene_path = get_tree().current_scene.scene_file_path
		save_manager.save_game()

		var save_confirm = Label.new()
		save_confirm.text = "Game Saved!"
		save_confirm.add_theme_font_size_override("font_size", 16)
		save_confirm.position = Vector2(0, 270)
		save_confirm.size = Vector2(400, 20)
		pause_panel.add_child(save_confirm)

		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(save_confirm):
			save_confirm.queue_free()

func _on_main_menu_pressed():
	# Unpause before changing scenes
	toggle_pause()
	
	# Return to main menu
	get_tree().change_scene_to_file("res://main_menu.tscn")
