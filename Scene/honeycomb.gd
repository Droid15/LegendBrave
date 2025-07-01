extends Area2D


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	get_tree().current_scene.show_honeycomb = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	get_tree().current_scene.show_honeycomb = false
