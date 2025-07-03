extends Area2D

func _init() -> void:
	body_entered.connect(enter_stage2)
	body_exited.connect(out_door)
func enter_stage2(player: Player) -> void:
	if not SceneMaster.stats.stageKey:
		var tips = player.find_child("tips")
		if tips:
			tips.visible = true
		return
	print("第二关")
	SceneMaster.stats.stageKey = false
	SceneMaster.change_scene("res://Scene/stage_2.tscn", "0.0")
	
func out_door(player: Player) -> void:
	var tips = player.find_child("tips")
	if tips:
		tips.visible = false
