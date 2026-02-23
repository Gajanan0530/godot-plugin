@tool
extends RefCounted

func build_error(message: String, error_type: String) -> Dictionary:
	return {
		"status": "error",
		"error": {
			"type": error_type,
			"message": message,
			"layer": "L2"
		}
	}

func build_success(schema: Dictionary, processing_time_ms: int) -> Dictionary:
	return {
		"status": "success",
		"behavior_schema": schema,
		"metadata": {
			"layer": "L2",
			"source_layer": "L1",
			"timestamp": Time.get_datetime_string_from_system(),
			"processing_time_ms": processing_time_ms
		}
	}
