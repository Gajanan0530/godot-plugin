@tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "My Plugin Dock Panel"
	dock.add_child(label)
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree():
	remove_control_from_docks(dock)
	dock.queue_free()
