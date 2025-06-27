extends Area2D

func _init() -> void:
	body_entered.connect(enter_stage2)

func enter_stage2(player: Player) -> void:
	if not SceneMaster.stats.stageKey:
		return
	print("第二关")
	SceneMaster.stats.stageKey = false
	SceneMaster.change_scene("res://Scene/stage_2.tscn", "0.0")
