@tool
extends EditorPlugin

func _enter_tree():
    print("Plugin enabled")

func _exit_tree():
    print("Plugin disabled")
