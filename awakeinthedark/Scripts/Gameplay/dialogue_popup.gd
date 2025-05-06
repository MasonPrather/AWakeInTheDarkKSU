extends Control

@export var dialogue_label: Label
@export var popup_duration: float = 5.0

func _ready():
	hide()  # Ensure the dialogue box is hidden at the start

func show_dialogue(text: String):
	dialogue_label.text = text
	show()
	get_tree().create_timer(popup_duration).timeout.connect(hide)
