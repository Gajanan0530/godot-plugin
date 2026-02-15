@tool
extends RefCounted

func build_success(input_text: String, processing_time_ms: int) -> Dictionary:
	return {
		"status": "success",
		"data": {
			"raw_user_description": input_text,
			"input_length": input_text.length()
		},
		"metadata": {
			"layer": "L1",
			"timestamp": Time.get_datetime_string_from_system(),
			"processing_time_ms": processing_time_ms
		}
	}

func build_error(message: String) -> Dictionary:
	return {
		"status": "error",
		"error": {
			"type": "VALIDATION_ERROR",
			"message": message,
			"layer": "L1"
		}
	}
