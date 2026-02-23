@tool
extends RefCounted

func evaluate(condition: Dictionary, context: Dictionary) -> bool:
	match condition.get("type", "generic"):

		"health_below":
			return context.get("player_health", 100) < condition.get("value", 0)

		"health_above":
			return context.get("player_health", 0) > condition.get("value", 0)

		"time_delay":
			return context.get("elapsed_time", 0) >= condition.get("value", 0)

		"location_enter":
			return context.get("player_entered_area", false)

		"location_exit":
			return context.get("player_exited_area", false)

		"proximity":
			return context.get("player_near", false)

		_:
			return false
