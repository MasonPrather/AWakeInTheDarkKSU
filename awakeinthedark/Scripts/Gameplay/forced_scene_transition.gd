extends Node

var cutscene_path = "res://cutscene.ogv"
var is_cutscene_playing := false
var skip_button
var pause_menu: CanvasLayer

func _ready():
	var canvas = CanvasLayer.new()
	canvas.name = "CanvasLayer"
	canvas.layer = 128
	add_child(canvas)

	# Background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.1, 0.15)
	canvas.add_child(bg)

	# Fade-in
	var fade = ColorRect.new()
	fade.name = "FadeOverlay"
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.color = Color.BLACK
	canvas.add_child(fade)
	fade.modulate.a = 1.0
	fade.create_tween().tween_property(fade, "modulate:a", 0.0, 1.0)

	# Title shadow
	var shadow = Label.new()
	shadow.text = "A Wake in the Dark"
	shadow.set_anchors_preset(Control.PRESET_TOP_WIDE)
	shadow.position.y = 104
	shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shadow.add_theme_font_size_override("font_size", 64)
	shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.4))
	canvas.add_child(shadow)

	# Title
	var title = Label.new()
	title.name = "Title"
	title.text = "A Wake in the Dark"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 100
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color.WHITE)
	canvas.add_child(title)

	# Menu Buttons
	var container = VBoxContainer.new()
	container.name = "ButtonContainer"
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.position = Vector2(-150, -120)
	container.custom_minimum_size = Vector2(300, 240)
	container.add_theme_constant_override("separation", 20)
	canvas.add_child(container)

	var load_button = Button.new()
	load_button.text = "LOAD GAME"
	load_button.add_theme_font_size_override("font_size", 28)
	load_button.add_theme_color_override("font_color_hover", Color.LIGHT_GREEN)
	load_button.add_theme_color_override("font_color_pressed", Color.GREEN)
	load_button.pressed.connect(_on_load_pressed)
	container.add_child(load_button)

	var exit_button = Button.new()
	exit_button.text = "EXIT"
	exit_button.add_theme_font_size_override("font_size", 28)
	exit_button.add_theme_color_override("font_color_hover", Color.DARK_RED)
	exit_button.add_theme_color_override("font_color_pressed", Color.RED)
	exit_button.pressed.connect(_on_exit_pressed)
	container.add_child(exit_button)

	var status = Label.new()
	status.name = "StatusLabel"
	status.text = "Ready"
	status.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status.position.y = -50
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 16)
	canvas.add_child(status)

	# Skip Button for Cutscene
	skip_button = Button.new()
	skip_button.name = "SkipButton"
	skip_button.text = "Skip"
	skip_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skip_button.offset_right = -20
	skip_button.offset_top = 20
	skip_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skip_button.visible = false
	skip_button.add_theme_font_size_override("font_size", 20)
	skip_button.pressed.connect(_on_cutscene_finished)
	canvas.add_child(skip_button)
	
	var new_game_button = Button.new()
	new_game_button.text = "NEW GAME"
	new_game_button.add_theme_font_size_override("font_size", 28)
	new_game_button.add_theme_color_override("font_color_hover", Color.ORANGE)
	new_game_button.add_theme_color_override("font_color_pressed", Color.DARK_ORANGE)
	new_game_button.pressed.connect(_on_new_game_pressed)
	container.add_child(new_game_button)

	# Pause Menu setup (for saving mid-game)
	pause_menu = CanvasLayer.new()
	pause_menu.name = "PauseMenu"
	pause_menu.visible = false
	add_child(pause_menu)

	var bg_pm = ColorRect.new()
	bg_pm.color = Color(0, 0, 0, 0.6)
	bg_pm.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_menu.add_child(bg_pm)

	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.custom_minimum_size = Vector2(300, 180)
	pause_menu.add_child(box)

	var save_btn = Button.new()
	save_btn.text = "Save Game"
	save_btn.pressed.connect(_on_save_game_pressed)
	box.add_child(save_btn)

	var resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.pressed.connect(_on_resume_pressed)
	box.add_child(resume_btn)


# === MENU BUTTON ACTIONS ===

func _on_start_pressed():
	update_status("Playing cutscene...")
	_play_cutscene(cutscene_path)
	
func _on_load_pressed():
	if SaveManager.save_exists():
		update_status("Loading saved game...")
		SaveManager.load_game()
	else:
		update_status("⚠️ No saved game found.")

func _on_exit_pressed():
	get_tree().quit()

# === CUTSCENE LOGIC ===

func _play_cutscene(path):
	var canvas = get_node_or_null("CanvasLayer")
	if canvas:
		canvas.visible = false

	var video = VideoStreamPlayer.new()
	video.name = "CutscenePlayer"
	video.set_anchors_preset(Control.PRESET_FULL_RECT)

	var stream = load(path)
	if stream == null:
		update_status("⚠️ Failed to load cutscene.")
		return

	video.stream = stream
	video.autoplay = true
	video.connect("finished", Callable(self, "_on_cutscene_finished"))
	add_child(video)
	video.play()
	is_cutscene_playing = true
	skip_button.visible = true

func _on_cutscene_finished():
	is_cutscene_playing = false

	var player = get_node_or_null("CutscenePlayer")
	if player:
		player.queue_free()

	skip_button.visible = false
	update_status("Cutscene finished. Starting new game...")

	SaveManager.delete_save()
	SaveManager.start_new_game()

# === PAUSE MENU ===

func _on_save_game_pressed():
	SaveManager.current_scene_path = get_tree().current_scene.scene_file_path
	SaveManager.save_game()
	pause_menu.visible = false
	get_tree().paused = false
	update_status("Game saved.")

func _on_resume_pressed():
	pause_menu.visible = false
	get_tree().paused = false

# === INPUT HANDLING ===

func _input(event):
	if is_cutscene_playing and event is InputEventKey and event.pressed:
		_on_cutscene_finished()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		pause_menu.visible = not pause_menu.visible
		get_tree().paused = pause_menu.visible

func _on_new_game_pressed():
	update_status("Starting a new game...")
	_play_cutscene(cutscene_path)

# === STATUS HELPER ===

func update_status(message):
	if has_node("CanvasLayer/StatusLabel"):
		$CanvasLayer/StatusLabel.text = message
