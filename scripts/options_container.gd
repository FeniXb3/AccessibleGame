extends PanelContainer

@onready var tab_container = %TabContainer

func _on_visibility_changed() -> void:
	if visible:
		tab_container.get_tab_bar().grab_focus()
