extends TouchScreenButton
@onready var set_panel: HBoxContainer = $"../../set_panel"



func _on_pressed() -> void:
	print("......")
	set_panel.visible = !set_panel.visible
	#OS.alert("gggg","title")

func _on_restart_pressed() -> void:
	print("重新开始.....")
	get_tree().reload_current_scene()


func _on_exit_pressed() -> void:
	print("退出游戏.....")
	get_tree().quit()
