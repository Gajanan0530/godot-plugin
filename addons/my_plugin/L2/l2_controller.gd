@tool
extends RefCounted

const SchemaContractClass = preload("res://addons/my_plugin/L2/schema_contract.gd")
const InterpreterClass = preload("res://addons/my_plugin/L2/rule_based_interpreter.gd")
const NormalizerClass = preload("res://addons/my_plugin/L2/schema_normalizer.gd")

var schema_contract: RefCounted
var interpreter: RefCounted
var normalizer: RefCounted

func _init():
	schema_contract = SchemaContractClass.new()
	interpreter = InterpreterClass.new()
	normalizer = NormalizerClass.new()



func process(l1_response: Dictionary) -> Dictionary:
	var start_time = Time.get_ticks_msec()

	# -------------------------------
	# L2 INPUT CONTRACT VALIDATION
	# -------------------------------

	if typeof(l1_response) != TYPE_DICTIONARY:
		return schema_contract.build_error(
			"L2 expects a Dictionary from L1.",
			"L2_INPUT_CONTRACT_VIOLATION"
		)

	if not l1_response.has("status") or l1_response["status"] != "success":
		return schema_contract.build_error(
			"L2 received non-success L1 response.",
			"L2_INPUT_CONTRACT_VIOLATION"
		)

	if not l1_response.has("data"):
		return schema_contract.build_error(
			"L1 response missing 'data' field.",
			"L2_INPUT_CONTRACT_VIOLATION"
		)

	var data = l1_response["data"]

	if not data.has("raw_user_description"):
		return schema_contract.build_error(
			"L1 response missing 'raw_user_description'.",
			"L2_INPUT_CONTRACT_VIOLATION"
		)

	if typeof(data["raw_user_description"]) != TYPE_STRING:
		return schema_contract.build_error(
			"'raw_user_description' must be a String.",
			"L2_INPUT_CONTRACT_VIOLATION"
		)

	var raw_text: String = data["raw_user_description"]

	# -------------------------------
	# RULE-BASED INTERPRETATION
	# -------------------------------

	var extracted_schema: Dictionary = interpreter.interpret(raw_text)
	var normalized_schema: Dictionary = normalizer.normalize(extracted_schema)


	var processing_time = Time.get_ticks_msec() - start_time

	# -------------------------------
	# BUILD L2 SUCCESS RESPONSE
	# -------------------------------

	return schema_contract.build_success(normalized_schema, processing_time)
