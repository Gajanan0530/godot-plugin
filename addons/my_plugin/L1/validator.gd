@tool
extends RefCounted

func validate(text: String) -> String:
	if text.strip_edges().is_empty():
		return "Input cannot be empty."
	return ""
