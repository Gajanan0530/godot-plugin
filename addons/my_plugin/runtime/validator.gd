extends RefCounted
class_name Validator


func validate(request: Dictionary) -> Dictionary:

	if not request.has("request_id"):
		return {
			"valid": false,
			"error": "Missing request_id"
		}

	if not request.has("context"):
		return {
			"valid": false,
			"error": "Missing context"
		}

	if not request.has("rule_set"):
		return {
			"valid": false,
			"error": "Missing rule_set"
		}

	return {
		"valid": true
	}
