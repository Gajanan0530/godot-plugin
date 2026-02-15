@tool
extends EditorPlugin

const UIController = preload("res://addons/my_plugin/L1/ui_controller.gd")

var ui_controller: RefCounted

func _enter_tree():
	ui_controller = UIController.new()
	var dock = ui_controller.create_dock()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree():
	if ui_controller:
		var dock = ui_controller.get_dock()
		if dock:
			remove_control_from_docks(dock)
		ui_controller.cleanup()
		ui_controller = null
