@tool
extends RefCounted

func normalize(schema: Dictionary) -> Dictionary:
	var normalized = {
		"behavior_rules": [],
		"states": [],
		"transitions": []
	}

	var conditions = schema.get("conditions", [])
	var actions = schema.get("actions", [])

	var rule_count = min(conditions.size(), actions.size())

	for i in rule_count:
		var classified_condition = _classify_condition(conditions[i]["name"])
		var classified_action = _classify_action(actions[i]["parameters"]["raw_action_text"])

		var rule = {
			"rule_id": "rule_" + str(i + 1),
			"priority": 10 - (i * 5),
			"repeatable": true,
			"cooldown_ms": 0,
			"enabled": true,
			"condition": classified_condition,
			"action": classified_action
		}

		normalized["behavior_rules"].append(rule)

	return normalized

# ============================
# CONDITION CLASSIFICATION
# ============================

func _classify_condition(text: String) -> Dictionary:
	var lower = text.to_lower()

	# --- TIME DELAY ---
	if lower.contains("second"):
		return {
			"type": "time_delay",
			"value": _extract_number(lower),
			"unit": "seconds",
			"raw": text
		}

	# --- HEALTH BELOW ---
	if lower.contains("health") and lower.contains("below"):
		return {
			"type": "health_below",
			"value": _extract_number(lower),
			"raw": text
		}

	# --- HEALTH ABOVE ---
	if lower.contains("health") and lower.contains("above"):
		return {
			"type": "health_above",
			"value": _extract_number(lower),
			"raw": text
		}

	# --- DISTANCE LESS ---
	if lower.contains("within") or lower.contains("less than"):
		return {
			"type": "distance_less_than",
			"value": _extract_number(lower),
			"raw": text
		}

	# --- DISTANCE GREATER ---
	if lower.contains("greater than") or lower.contains("far"):
		return {
			"type": "distance_greater_than",
			"value": _extract_number(lower),
			"raw": text
		}

	# --- LOCATION ENTER ---
	if lower.contains("enter"):
		return {
			"type": "location_enter",
			"raw": text
		}

	# --- LOCATION EXIT ---
	if lower.contains("exit") or lower.contains("leave"):
		return {
			"type": "location_exit",
			"raw": text
		}

	# --- PROXIMITY ---
	if lower.contains("near") or lower.contains("close"):
		return {
			"type": "proximity",
			"raw": text
		}

	return {
		"type": "generic",
		"raw": text
	}


# ============================
# ACTION CLASSIFICATION
# ============================

func _classify_action(text: String) -> Dictionary:
	var lower = text.to_lower()

	# --- SPAWN ---
	if lower.begins_with("spawn"):
		return {
			"type": "spawn",
			"count": _extract_number(lower),
			"raw": text
		}

	# --- DESPAWN ---
	if lower.begins_with("despawn"):
		return {
			"type": "despawn",
			"raw": text
		}

	# --- LOCK ---
	if lower.begins_with("lock"):
		return {
			"type": "lock",
			"raw": text
		}

	# --- UNLOCK ---
	if lower.begins_with("unlock"):
		return {
			"type": "unlock",
			"raw": text
		}

	# --- ATTACK ---
	if lower.begins_with("attack"):
		return {
			"type": "attack",
			"raw": text
		}

	# --- FLEE ---
	if lower.begins_with("flee"):
		return {
			"type": "flee",
			"raw": text
		}

	# --- MOVE ---
	if lower.begins_with("move"):
		return {
			"type": "move",
			"raw": text
		}

	# --- PATROL ---
	if lower.begins_with("patrol"):
		return {
			"type": "patrol",
			"raw": text
		}

	# --- HEAL ---
	if lower.begins_with("heal"):
		return {
			"type": "heal",
			"value": _extract_number(lower),
			"raw": text
		}

	# --- DAMAGE ---
	if lower.begins_with("damage"):
		return {
			"type": "damage",
			"value": _extract_number(lower),
			"raw": text
		}

	# --- PLAY ANIMATION ---
	if lower.begins_with("play"):
		return {
			"type": "play_animation",
			"raw": text
		}

	return {
		"type": "generic",
		"raw": text
	}


# ============================
# NUMBER EXTRACTION
# ============================

func _extract_number(text: String) -> int:
	var digits = ""
	for char in text:
		if char.is_valid_int():
			digits += char
		elif digits != "":
			break

	if digits != "":
		return int(digits)

	return 0
