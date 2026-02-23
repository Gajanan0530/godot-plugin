@tool
extends RefCounted

var trigger_keywords := ["when", "if", "on", "after", "while"]

func interpret(raw_text: String) -> Dictionary:
	var schema = {
		"states": [],
		"transitions": [],
		"actions": [],
		"conditions": []
	}

	if raw_text.strip_edges().is_empty():
		return schema

	var clauses = _split_into_clauses(raw_text)

	for clause in clauses:
		var parsed = _parse_clause(clause)
		if parsed.size() == 2:
			var condition = parsed[0]
			var action = parsed[1]

			schema["conditions"].append({
				"name": condition
			})

			schema["actions"].append({
				"name": _extract_primary_verb(action),
				"parameters": {
					"raw_action_text": action
				}
			})

	return schema


# -----------------------------
# SAFE CLAUSE SPLITTING
# -----------------------------
func _split_into_clauses(text: String) -> Array:
	var normalized = text.replace("!", ".").replace("?", ".")
	var raw_clauses = normalized.split(".")
	
	var cleaned = []
	for c in raw_clauses:
		var trimmed = c.strip_edges()
		if not trimmed.is_empty():
			cleaned.append(trimmed)
	
	return cleaned


# -----------------------------
# STRICT CLAUSE PARSING
# -----------------------------
func _parse_clause(clause: String) -> Array:
	var lower_clause = clause.to_lower()

	for keyword in trigger_keywords:
		var pattern = " " + keyword + " "
		
		# Condition-first: starts with keyword
		if lower_clause.begins_with(keyword + " "):
			return _parse_condition_first(clause, keyword)
		
		# Action-first: contains keyword surrounded by spaces
		var keyword_pos = lower_clause.find(pattern)
		if keyword_pos != -1:
			return _parse_action_first(clause, keyword, keyword_pos + 1)

	return []


func _parse_condition_first(clause: String, keyword: String) -> Array:
	var without_keyword = clause.substr(keyword.length()).strip_edges()

	var comma_index = without_keyword.find(",")
	if comma_index == -1:
		return []

	var condition = without_keyword.substr(0, comma_index).strip_edges()
	var action = without_keyword.substr(comma_index + 1).strip_edges()

	return [condition, action]


func _parse_action_first(clause: String, keyword: String, keyword_start: int) -> Array:
	var action = clause.substr(0, keyword_start).strip_edges()
	var condition = clause.substr(keyword_start + keyword.length()).strip_edges()

	return [condition, action]


# -----------------------------
# VERB EXTRACTION
# -----------------------------
func _extract_primary_verb(action_text: String) -> String:
	var words = action_text.strip_edges().split(" ")
	if words.size() > 0:
		return words[0].to_lower()
	return "unknown"
