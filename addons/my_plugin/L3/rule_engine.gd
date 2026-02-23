@tool
extends RefCounted

# ===============================
# Configuration
# ===============================

var execution_mode: String = "highest_only" # "fire_all" | "highest_only"

# ===============================
# Internal State Tracking
# ===============================

var active_rule_id: String = ""
var last_executed_rule_id: String = ""

var previous_active_rule_id: String = ""

var execution_history: Array = []

var internal_time_ms: int = 0
var state_enter_time_ms: int = 0
var state_duration_ms: int = 0

# Cooldown tracking
var cooldown_tracker := {}

# Dependencies
var condition_evaluator
var action_executor


# ===============================
# Initialization
# ===============================

func _init(cond_eval = null, act_exec = null):
	condition_evaluator = cond_eval
	action_executor = act_exec


# ===============================
# Core Evaluation
# ===============================

func evaluate(rules: Array, context: Dictionary) -> void:

	internal_time_ms = Time.get_ticks_msec()
	previous_active_rule_id = active_rule_id

	var sorted_rules = rules.duplicate()

	# Sort by priority descending
	sorted_rules.sort_custom(func(a, b):
		return a.get("priority", 0) > b.get("priority", 0)
	)

	var rule_triggered := false

	for rule in sorted_rules:

		if not rule.get("enabled", true):
			continue

		var rule_id = rule.get("rule_id", "")

		if _is_on_cooldown(rule_id):
			continue

		var condition = rule.get("condition", {})
		var action = rule.get("action", {})

		if condition_evaluator and condition_evaluator.evaluate(condition, context):

			rule_triggered = true

			# State tracking (dominant rule logic)
			if execution_mode == "highest_only":
				active_rule_id = rule_id

				if active_rule_id != previous_active_rule_id:
					state_enter_time_ms = internal_time_ms
					_on_rule_exit(previous_active_rule_id)
					_on_rule_enter(active_rule_id)

				state_duration_ms = internal_time_ms - state_enter_time_ms

			last_executed_rule_id = rule_id

			execution_history.append({
				"rule_id": rule_id,
				"time": internal_time_ms
			})

			print("Executing rule:", rule_id)

			if action_executor:
				action_executor.execute(action, context)

			if not rule.get("repeatable", true):
				rule["enabled"] = false

			_apply_cooldown(rule_id, rule.get("cooldown_ms", 0))

			if execution_mode == "highest_only":
				return
	
	# If no rule triggered in highest_only mode
	if execution_mode == "highest_only" and not rule_triggered:
		active_rule_id = ""
		
	

# ===============================
# Cooldown System
# ===============================

func _is_on_cooldown(rule_id: String) -> bool:
	if not cooldown_tracker.has(rule_id):
		return false

	return internal_time_ms < cooldown_tracker[rule_id]


func _apply_cooldown(rule_id: String, cooldown_ms: int) -> void:
	if cooldown_ms <= 0:
		return

	cooldown_tracker[rule_id] = internal_time_ms + cooldown_ms


# ===============================
# Transition Hooks
# ===============================

func _on_rule_enter(rule_id: String) -> void:
	if rule_id == "":
		return
	print("ENTER RULE:", rule_id)


func _on_rule_exit(rule_id: String) -> void:
	if rule_id == "":
		return
	print("EXIT RULE:", rule_id)


# ===============================
# Debug Utilities
# ===============================

func debug_state() -> void:
	print("Active Rule:", active_rule_id)
	print("Last Executed Rule:", last_executed_rule_id)
	print("State Duration (ms):", state_duration_ms)
	print("Execution History:", execution_history)
	
