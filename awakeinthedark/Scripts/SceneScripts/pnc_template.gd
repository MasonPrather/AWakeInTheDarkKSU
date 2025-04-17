extends Node2D

signal RevealItem

func _ready() -> void:
	# Sprites not visible at start
	$Test1Item.visible = false
	$Test2Item.visible = false
	$Test3Item.visible = false

# Interactions from collectible items
func handle_item_interaction(item_name):
	match item_name:
		"test1":
			$Test1Item.visible = true
			print("Test 1 clicked..")
			
		"test2":
			$Test2Item.visible = true
			print("Test 2 clicked...")
			
		"test3":
			$Test3Item.visible = true
			print("Test 3 clicked...")
	
# For revealing hidden collectible items		
func reveal_item():
	if $Test3CollectibleObject:
		$Test3CollectibleObject.position = Vector2(227, 97)
		print("Test3Item revealed at new position.")
	else:
		print("Test3Item not found!")
