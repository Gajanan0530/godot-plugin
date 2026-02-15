@tool
extends RefCounted

const ValidatorClass = preload("res://addons/my_plugin/L1/validator.gd")
const ResponseBuilderClass = preload("res://addons/my_plugin/L1/response_builder.gd")

var dock: Control
var input_field: TextEdit
var generate_button: Button
var error_label: Label

var validator: RefCounted
var response_builder: RefCounted

func create_dock() -> Control:
	validator = ValidatorClass.new()
	response_builder = ResponseBuilderClass.new()

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
	if not input_field or not validator or not response_builder:
		return

	error_label.text = ""
	var start_time = Time.get_ticks_msec()

	var input_text = input_field.text
	var result = validator.validate(input_text)

	if not result.get("valid", false):
		var error_message = result.get("error", "Unknown validation error.")
		var error_response = response_builder.build_error(error_message)
		error_label.text = error_message
		print(error_response)
		return

	var processing_time = Time.get_ticks_msec() - start_time
	var success_response = response_builder.build_success(input_text, processing_time)
	print(success_response)

func cleanup() -> void:
	if dock:
		dock.queue_free()
		dock = null

	input_field = null
	generate_button = null
	error_label = null
	validator = null
	response_builder = null
