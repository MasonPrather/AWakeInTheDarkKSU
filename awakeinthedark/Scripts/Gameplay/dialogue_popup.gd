extends Control

# Time duration for popups
var display_time = 7.0

# Reference to label
@onready var label = $Label

# Timer for auto-closing
var timer = null

func _ready():
	# Set up timer
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	
	# Hide initially
	visible = false

func _input(event):
	# Check for mouse click anywhere
	if visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Close popup when clicked
		visible = false
		timer.stop()

func show_dialogue(text: String):
	# Set text
	label.text = text
	
	# Show popup
	visible = true
	
	# Reset and start timer for auto-close
	timer.stop()
	timer.wait_time = display_time
	timer.start()

func _on_timer_timeout():
	# Hide popup when timer completes
	visible = false

func set_display_time(seconds: float):
	display_time = seconds
