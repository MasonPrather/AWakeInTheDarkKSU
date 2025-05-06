extends Node2D

@onready var click_sound = $ClickSoundPlayer
@onready var inventory_sound = $InventorySoundPlayer
@onready var clue_sound := $ClueSoundPlayer
@onready var victory_sound := $VictorySoundPlayer
@onready var item_bar = $ItemInventoryBar
@onready var inspection_ui = get_tree().get_current_scene().find_child("InspectionUI", true, false)

@onready var wheel_item = item_bar.get_node("WheelItem")
@onready var book1_item = item_bar.get_node("Book1Item")
@onready var book2_item = item_bar.get_node("Book2Item")
@onready var painting_item = item_bar.get_node("PaintingItem")
@onready var combo_code_item = item_bar.get_node("ComboCodeItem")

func _ready() -> void:
	# Hide all item visuals initially
	wheel_item.visible = false
	book1_item.visible = false
	book2_item.visible = false
	painting_item.visible = false
	combo_code_item.visible = false

	# Load SFX
	click_sound.stream = load("res://Audio/sfx/rclick-13693.mp3")
	inventory_sound.stream = load("res://Audio/sfx/item-equip-6904.mp3")
	
	# Connect inventory buttons to inspection logic
	wheel_item.pressed.connect(_on_item_inspect.bind("res://Art/Textures/items/hd_wheel.png", "wheel"))
	book1_item.pressed.connect(_on_item_inspect.bind("res://Art/Textures/items/hd_book1.png", "book1"))
	book2_item.pressed.connect(_on_item_inspect.bind("res://Art/Textures/items/hd_book2.png", "book2"))
	painting_item.pressed.connect(_on_item_inspect.bind("res://Art/Textures/items/hd_painting.png", "painting"))
	combo_code_item.pressed.connect(_on_item_inspect.bind("res://Art/Textures/items/combo.png", "combo_code"))

	# Sync collected items
	restore_inventory_visuals()

# Play SFX
func play_click_sound(): click_sound.play()
func play_inventory_sound(): inventory_sound.play()
func play_clue_sound(): clue_sound.play()
func play_victory_sound(): victory_sound.play()

# Inventory Item Inspection Logic
func _on_item_inspect(texture_path: String, item_name: String):
	if inspection_ui:
		var tex = load(texture_path)
		inspection_ui.inspect_item(tex, item_name)
	else:
		push_warning("❌ InspectionUI not found.")

# Interaction Router
func handle_item_interaction(item_name: String):
	play_click_sound()
	var popup := get_tree().get_current_scene().find_child("Popup", true, false)

	match item_name:
		"lamp":
			popup.show_dialogue("The lamp dimly lights the area - warm to the touch.")
		"crate":
			popup.show_dialogue("A large crate. There are 10 cannonballs inside.")
			if not SaveManager.get_state("hallway_crate_flag", false):
				play_clue_sound()
				SaveManager.set_state("hallway_crate_flag", true)
				check_clue_progress()	
		"door1":
			popup.show_dialogue("The door is locked tight. There's no key.")
		"door2":
			if SaveManager.inventory_items.has("combo_code"):
				popup.show_dialogue("The padlock clicks... your code was correct.")
				#await get_tree().create_timer(2).timeout
				
				# Show padlock cutscene UI
				#var cutscene_ui = get_tree().get_current_scene().find_child("UnlockCutsceneUI", true, false)
				#if cutscene_ui:
					#cutscene_ui.visible = true
				
				play_victory_sound()

				# Scene transition after short delay
				await get_tree().create_timer(2.75).timeout
				change_scene("res://Scenes/bridge.tscn")
			else:
				popup.show_dialogue("The door is locked by a combination padlock. Could there be a code in this room?")
		"wheel":
			wheel_item.visible = true
			popup.show_dialogue("An old, rusted ship's wheel.")
			add_to_inventory("wheel")
		"book1":
			book1_item.visible = true
			popup.show_dialogue("The title reads: Captain's Journal: Final Voyage.")
			add_to_inventory("book1")
		"book2":
			book2_item.visible = true
			popup.show_dialogue("A dusty volume on nautical knots.")
			add_to_inventory("book2")
		"painting":
			if SaveManager.get_state("book1_read", false):
				popup.show_dialogue("The painting seems to be watching you... something is etched in its eye.")
				painting_item.visible = true	
				add_to_inventory("painting")
			else:
				popup.show_dialogue("A large fish painting. Oddly detailed.")
		"combo_code":
			combo_code_item.visible = true
			popup.show_dialogue("It's a slip of paper with the numbers '4-8-7'.")
			add_to_inventory("combo_code")
		"hallway_1":
			change_scene("res://Scenes/hallway_1.tscn")
		"hallway_2":
			change_scene("res://Scenes/hallway_2.tscn")

func check_clue_progress():
	# Count the number of clue flags set to true
	var progress_flags = [
		SaveManager.get_state("book1_read", false),
		SaveManager.get_state("painting_code", false),
		SaveManager.get_state("wheel_code", false),
		SaveManager.get_state("hallway_crate_flag", false)
	]

	var count := 0
	for flag in progress_flags:
		if flag:
			count += 1

	# If all 4 are complete and combo code not yet granted
	if count == 4 and not SaveManager.inventory_items.has("combo_code"):
		print("All clues found! Unlocking combo code.")
		combo_code_item.visible = true
		add_to_inventory("combo_code")
		play_clue_sound()

# Global Inventory (via SaveManager)
func add_to_inventory(item: String):
	if not SaveManager.inventory_items.has(item):
		SaveManager.add_to_inventory(item)
		play_inventory_sound()
		print("Added %s to global inventory" % item)

func restore_inventory_visuals():
	for item in SaveManager.inventory_items:
		match item:
			"wheel": wheel_item.visible = true
			"book1": book1_item.visible = true
			"book2": book2_item.visible = true
			"painting": painting_item.visible = true
			"combo_code": combo_code_item.visible = true

func change_scene(path: String):
	SaveManager.current_scene_path = path
	SaveManager.save_game()
	get_tree().change_scene_to_file(path)
