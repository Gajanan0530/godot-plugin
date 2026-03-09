@tool
extends RefCounted

# ===============================
# L2
# ===============================
const L2ControllerClass = preload("res://addons/my_plugin/L2/l2_controller.gd")

# ===============================
# L3
# ===============================
const RuleEngineClass = preload("res://addons/my_plugin/L3/rule_engine.gd")
const ConditionEvaluatorClass = preload("res://addons/my_plugin/L3/condition_evaluator.gd")
const ActionExecutorClass = preload("res://addons/my_plugin/L3/action_executor.gd")

# ===============================
# L1
# ===============================
const ValidatorClass = preload("res://addons/my_plugin/L1/validator.gd")
const ResponseBuilderClass = preload("res://addons/my_plugin/L1/response_builder.gd")

# ===============================
# L4 Runtime Pipeline
# ===============================
const PipelineExecutorClass = preload("res://addons/my_plugin/runtime/pipeline_executor.gd")

# ===============================
# UI State
# ===============================
var l2_controller: RefCounted
var dock: Control
var input_field: TextEdit
var generate_button: Button
var error_label: Label

# ===============================
# Core Components
# ===============================
var validator: RefCounted
var response_builder: RefCounted
var rule_engine: RefCounted
var executor: RefCounted


# ===============================
# Create Plugin Dock
# ===============================
func create_dock() -> Control:

	validator = ValidatorClass.new()
	response_builder = ResponseBuilderClass.new()
	l2_controller = L2ControllerClass.new()

	var condition_evaluator = ConditionEvaluatorClass.new()
	var action_executor = ActionExecutorClass.new()
	rule_engine = RuleEngineClass.new(condition_evaluator, action_executor)

	executor = PipelineExecutorClass.new(
		validator,
		rule_engine,
		response_builder
	)

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


# ===============================
# Generate Button Logic
# ===============================
func _on_generate_pressed() -> void:

	if not input_field or not validator or not response_builder:
		return

	error_label.text = ""

	var start_time = Time.get_ticks_msec()
	var input_text = input_field.text

	# ===============================
	# L1 Validation
	# ===============================

	var result = validator.validate(input_text)

	if not result.get("valid", false):

		var error_message = result.get("error", "Unknown validation error.")
		var error_response = response_builder.build_error(error_message)

		error_label.text = error_message
		print(error_response)

		return


	# ===============================
	# L2 Processing
	# ===============================

	var l2_response = l2_controller.process({
		"status": "success",
		"data": {
			"raw_user_description": input_text
		}
	})

	print(l2_response)

	if l2_response.get("status") != "success":
		return


	# ===============================
	# Prepare L3 Rule Data
	# ===============================

	var rules = l2_response["behavior_schema"]["behavior_rules"]

	# Fake context for now
	var context = {
		"player_health": 40,
		"elapsed_time": 0,
		"player_in_area": true
	}

	# ===============================
	# L4 Runtime Pipeline Execution
	# ===============================

	var request = {
		"request_id": "npc_behavior_test",
		"rule_set": rules,
		"context": context
	}

	var pipeline_result = executor.execute(request)

	print("Pipeline Result: ", pipeline_result)

	if pipeline_result.get("status") != "success":
		error_label.text = pipeline_result.get("message", "Execution failed.")
		return

	var end_time = Time.get_ticks_msec()
	print("Execution Time (ms): ", end_time - start_time)


# ===============================
# Cleanup
# ===============================
func cleanup() -> void:

	if dock:
		dock.queue_free()
		dock = null

	input_field = null
	generate_button = null
	error_label = null

	validator = null
	response_builder = null
	rule_engine = null
	executor = null
