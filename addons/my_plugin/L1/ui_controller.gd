@tool
extends RefCounted

var dock: Control

func create_dock() -> Control:
	dock = VBoxContainer.new()

	var label = Label.new()
	label.text = "My Plugin Dock Panel"
	dock.add_child(label)

	return dock

func get_dock() -> Control:
	return dock

func cleanup() -> void:
	if dock:
		dock.queue_free()
		dock = null
