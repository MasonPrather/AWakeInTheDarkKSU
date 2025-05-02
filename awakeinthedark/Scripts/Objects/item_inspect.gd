extends Node

@onready var inspect_overlay := $InspectOverlay
@onready var inspect_image := $InspectOverlay/InspectImage
@onready var dim_background := $InspectOverlay/DimBackground

@onready var wheel_item := $WheelItem
@onready var book1_item := $Book1Item
@onready var book2_item := $Book2Item
@onready var painting_item := $PaintingItem
@onready var combo_code_item := $ComboCodeItem

var is_inspecting := false

func _ready():
	inspect_overlay.visible = false
	set_process_input(true)

	# Set all items to trigger inspection on click
	connect_item_for_inspection(wheel_item)
	connect_item_for_inspection(book1_item)
	connect_item_for_inspection(book2_item)
	connect_item_for_inspection(painting_item)
	connect_item_for_inspection(combo_code_item)

func connect_item_for_inspection(item: TextureRect):
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	item.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_inventory_item_clicked(item.texture))

func on_inventory_item_clicked(texture: Texture):
	if texture:
		inspect_image.texture = texture
		inspect_overlay.visible = true
		is_inspecting = true
		get_tree().paused = true

func _input(event):
	if is_inspecting and event is InputEventMouseButton and event.pressed:
		inspect_overlay.visible = false
		inspect_image.texture = null
		is_inspecting = false
		get_tree().paused = false
