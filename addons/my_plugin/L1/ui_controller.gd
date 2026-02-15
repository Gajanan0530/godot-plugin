@tool
extends RefCounted
const Validator = preload("res://addons/my_plugin/L1/validator.gd")

var dock: Control
var input_field: TextEdit
var generate_button: Button
var error_label: Label

func create_dock() -> Control:
	dock = VBoxContainer.new()
	
	var title_label = Label.new()
	title_label.text = "AI NPC Behavior Designer"
	dock.add_child(title_label)
	
	input_field = TextEdit.new()
	input_field.custom_minimum_size = Vector2(0, 100)
	input_field.placeholder_text = "Enter behavior description..."
	dock.add_child(input_field)
	
	generate_button = Button.new()
	generate_button.text = "Generate"
	generate_button.pressed.connect(_on_generate_pressed)
	dock.add_child(generate_button)
	
	error_label = Label.new()
	error_label.add_theme_color_override("font_color", Color.RED)
	dock.add_child(error_label)
	
	return dock

func get_dock() -> Control:
	return dock

func _on_generate_pressed() -> void:
	if not input_field:
		return

	error_label.text = ""

	var input_text = input_field.text
	var result = Validator.new().validate(input_text)

	if not result.get("valid", false):
		error_label.text = result.get("error", "Unknown validation error.")
		return

	print("Validation Passed:")
	print(input_text)

func cleanup() -> void:
	if dock:
		dock.queue_free()
		dock = null
	input_field = null
	generate_button = null
	error_label = null
