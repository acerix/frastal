extends HBoxContainer

@export var label: String = "Label"
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var step: float = 0.01
@export var value: float = 0.0

@onready var label_node = $Label
@onready var slider_node = $HSlider
@onready var line_edit_node = $LineEdit

func _ready():
	label_node.text = label
	slider_node.min_value = min_value
	slider_node.max_value = max_value
	slider_node.step = step
	slider_node.value = value
	line_edit_node.text = str(value)
	
	slider_node.value_changed.connect(_on_slider_changed)
	line_edit_node.text_submitted.connect(_on_line_edit_submitted)

func _on_slider_changed(new_value):
	line_edit_node.text = str(new_value)
	value = new_value

func _on_line_edit_submitted(new_text):
	slider_node.value = float(new_text)
	value = float(new_text)

func get_value() -> float:

	return value



func set_value(new_value):

	value = new_value

	slider_node.value = new_value

	line_edit_node.text = str(new_value)
