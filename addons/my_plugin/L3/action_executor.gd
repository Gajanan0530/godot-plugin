@tool
extends RefCounted

func execute(action: Dictionary, context: Dictionary) -> void:
	match action.get("type", "generic"):

		"attack":
			print("Action: NPC attacks player")

		"spawn":
			print("Action: Spawning %d entities" % action.get("count", 1))

		"unlock":
			print("Action: Unlocking doors")

		"lock":
			print("Action: Locking doors")

		"heal":
			print("Action: Healing", action.get("value", 0))

		_:
			print("Action:", action.get("type", "unknown"))
