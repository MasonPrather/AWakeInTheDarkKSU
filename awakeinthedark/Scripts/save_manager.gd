extends Node

signal save_completed
signal load_completed

var inventory_items: Array = []
var game_state: Dictionary = {}
var current_scene_path: String = "res://Scenes/captains_cabin.tscn"

func _ready():
	pass 

# === SAVE GAME ===
func save_game():
	var save_data = {
		"inventory": inventory_items,
		"game_state": game_state,
		"scene_path": current_scene_path
	}

	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	emit_signal("save_completed")

# === LOAD GAME ===
func load_game():
	if not save_exists():
		print("⚠️ No save file found.")
		return

	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file == null:
		print("⚠️ Failed to open save file.")
		return

	var save_data = file.get_var()
	file.close()

	inventory_items = save_data.get("inventory", [])
	game_state = save_data.get("game_state", {})
	current_scene_path = save_data.get("scene_path", "res://Scenes/captains_cabin.tscn")

	var scene = load(current_scene_path)
	if scene:
		get_tree().change_scene_to_packed(scene)
		emit_signal("load_completed")
	else:
		print("⚠️ Failed to load saved scene.")
		start_new_game()

# === NEW GAME ===
func start_new_game():
	inventory_items = []
	game_state = {}
	current_scene_path = "res://Scenes/captains_cabin.tscn"
	var scene = load(current_scene_path)
	get_tree().change_scene_to_packed(scene)
	


# === UTILITY ===
func save_exists() -> bool:
	return FileAccess.file_exists("user://save_game.dat")

func delete_save():
	if FileAccess.file_exists("user://save_game.dat"):
		DirAccess.remove_absolute("user://save_game.dat")
		
func add_to_inventory(item_name: String):
	if not inventory_items.has(item_name):
		inventory_items.append(item_name)

# === GAME STATE GET/SET ===
func set_state(key: String, value):
	game_state[key] = value

func get_state(key: String, default = null):
	return game_state.get(key, default)
