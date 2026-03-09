extends RefCounted
class_name PipelineExecutor

var validator
var rule_engine
var response_builder


func _init(_validator, _rule_engine, _response_builder):
	validator = _validator
	rule_engine = _rule_engine
	response_builder = _response_builder


func execute(request: Dictionary) -> Dictionary:

	# Step 1: Validate request
	var validation_result = validator.validate(request)
	if not validation_result["valid"]:
		return response_builder.build_error(validation_result["error"])


	# Step 2: Execute rule engine
	var engine_result = rule_engine.evaluate(request)


	# Step 3: Build response
	return response_builder.build_success(engine_result)
