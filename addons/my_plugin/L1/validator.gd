#@tool
extends RefCounted

func validate(input_text: String) -> Dictionary:
	if input_text == null:
		return { "valid": false, "error": "Input cannot be null." }

	var trimmed = input_text.strip_edges()

	if trimmed.is_empty():
		return { "valid": false, "error": "Input cannot be empty." }

	if trimmed.length() < 10:
		return { "valid": false, "error": "Input must be at least 10 characters long." }

	if trimmed.length() > 2000:
		return { "valid": false, "error": "Input must not exceed 2000 characters." }

	if trimmed.contains("func ") or trimmed.contains("{") or trimmed.contains("}"):
		return { "valid": false, "error": "Input contains forbidden script-like patterns." }

	return { "valid": true }
