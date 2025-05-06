extends CanvasLayer

@onready var dim_bg := $DimBackground
@onready var hd_image := $HDItemImage

var is_inspecting := false
var current_item_name := ""

func _ready():
	visible = false
	set_process_input(true)

	# Block clicks from going through the inspection UI
	hd_image.mouse_filter = Control.MOUSE_FILTER_STOP
	dim_bg.mouse_filter = Control.MOUSE_FILTER_STOP

	# Set dim background size and position
	dim_bg.custom_minimum_size = Vector2(1000, 1000)
	dim_bg.anchor_left = 0.5
	dim_bg.anchor_top = 0.5
	dim_bg.anchor_right = 0.5
	dim_bg.anchor_bottom = 0.5
	dim_bg.offset_left = -500
	dim_bg.offset_top = -500
	dim_bg.offset_right = 500
	dim_bg.offset_bottom = 500

func inspect_item(texture: Texture2D, item_name: String):
	if texture == null:
		push_warning("No texture provided to Inspection UI.")
		return

	is_inspecting = true
	current_item_name = item_name
	visible = true
	hd_image.texture = texture

	# Reference the root scene (e.g. hallway.gd)
	var scene = get_tree().get_current_scene()

	match item_name:
		"book1":
			SaveManager.set_state("book1_read", true)
			print("📘 Book 1 inspected. 'book1_read' set to true.")
			if scene.has_method("play_clue_sound"):
				scene.play_clue_sound()
			if scene.has_method("check_clue_progress"):
				scene.check_clue_progress()

		"painting":
			if SaveManager.get_state("book1_read", false):
				SaveManager.set_state("painting_code", true)
				print("🎯 Painting inspected after book1. 'painting_code' set to true.")
				if scene.has_method("play_clue_sound"):
					scene.play_clue_sound()
				if scene.has_method("check_clue_progress"):
					scene.check_clue_progress()
			else:
				print("👁️‍🗨️ Painting inspected, but book1 has not been read.")

		"wheel":
			SaveManager.set_state("wheel_code", true)
			print("🛞 Wheel inspected. 'wheel_code' set to true.")
			if scene.has_method("play_clue_sound"):
				scene.play_clue_sound()
			if scene.has_method("check_clue_progress"):
				scene.check_clue_progress()	
				
	# Get the viewport (screen) size
	var screen_size: Vector2 = get_viewport().get_visible_rect().size * 1.66
	var tex_size: Vector2 = texture.get_size()

	# Compute scale factor (maintain aspect ratio)
	var scale_factor: float = min(screen_size.x / tex_size.x, screen_size.y / tex_size.y)
	var final_size: Vector2 = tex_size * scale_factor

	# Resize the TextureRect
	hd_image.custom_minimum_size = final_size
	hd_image.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hd_image.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Center the image using anchors and offsets
	hd_image.anchor_left = 0.5
	hd_image.anchor_top = 0.5
	hd_image.anchor_right = 0.5
	hd_image.anchor_bottom = 0.5
	hd_image.offset_left = -final_size.x / 4
	hd_image.offset_top = -final_size.y / 4
	hd_image.offset_right = final_size.x / 4
	hd_image.offset_bottom = final_size.y / 4

func _input(event):
	if is_inspecting and event is InputEventMouseButton and event.pressed:
		visible = false
		hd_image.texture = null
		is_inspecting = false
		current_item_name = ""
		get_viewport().set_input_as_handled()
