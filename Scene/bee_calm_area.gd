extends Area2D

func _ready() -> void:
	body_entered.connect(player_entered)
	#body_exited.connect(player_exited)
	
#进入蜂巢冷静范围
func player_entered(e) -> void:
	if e.name=='Player':
		get_tree().current_scene.show_honeycomb = false
	
func player_exited(e) -> void:
	if e.name=='Player':
		get_tree().current_scene.show_honeycomb = true
