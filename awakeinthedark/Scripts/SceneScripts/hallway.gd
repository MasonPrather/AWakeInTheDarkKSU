extends Node2D

@onready var click_sound = $ClickSoundPlayer
@onready var inventory_sound = $InventorySoundPlayer

@onready var wheel_item = $WheelItem
@onready var book1_item = $Book1Item
@onready var book2_item = $Book2Item
@onready var painting_item = $PaintingItem
@onready var combo_code_item = $ComboCodeItem

func _ready() -> void:
	# Hide all item visuals initially
	wheel_item.visible = false
	book1_item.visible = false
	book2_item.visible = false
	painting_item.visible = false
	combo_code_item.visible = false

	click_sound.stream = load("res://Audio/sfx/rclick-13693.mp3")
	inventory_sound.stream = load("res://Audio/sfx/item-equip-6904.mp3")

# Play SFX
func play_click_sound(): click_sound.play()
func play_inventory_sound(): inventory_sound.play()

# Interaction Router
func handle_item_interaction(item_name: String):
	play_click_sound()
	var popup = get_node("/root/Hallway/Popup")

	match item_name:
		"wheel":
			wheel_item.visible = true
			popup.show_dialogue("An old, rusted ship's wheel.")
			add_to_inventory("wheel")

		"book1":
			book1_item.visible = true
			popup.show_dialogue("The title reads: *Captain's Journal: Final Voyage*.")
			add_to_inventory("book1")

		"book2":
			book2_item.visible = true
			popup.show_dialogue("A dusty volume on nautical knots.")
			add_to_inventory("book2")

		"painting":
			painting_item.visible = true
			if SaveManager.inventory_items.has("book1"):
				popup.show_dialogue("The painting seems to be watching you... something is etched in its eye.")
				SaveManager.set_state("fish_code_seen", true)
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

# Global Inventory (via SaveManager)
func add_to_inventory(item: String):
	if not SaveManager.inventory_items.has(item):
		SaveManager.add_to_inventory(item)
		play_inventory_sound()
		print("Added %s to global inventory" % item)

func change_scene(path: String):
	SaveManager.current_scene_path = path
	SaveManager.save_game()
	get_tree().change_scene_to_file(path)
