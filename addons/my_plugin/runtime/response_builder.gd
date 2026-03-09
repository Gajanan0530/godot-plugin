extends RefCounted
class_name ResponseBuilder


func build_success(engine_result: Dictionary) -> Dictionary:
	return {
		"status": "success",
		"data": engine_result
	}


func build_error(error_message: String) -> Dictionary:
	return {
		"status": "error",
		"message": error_message
	}
