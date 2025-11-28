extends Area2D

func _init() -> void:
	body_entered.connect(enter_stage_boss)

func enter_stage_boss(player: Player) -> void:
	print("boss关")
	if SceneMaster.stats.stageKey==false :
		return 
	SceneMaster.stats.stageKey = false
	#SceneMaster.change_scene("res://world.tscn", "0.0")
	SceneMaster.change_scene("res://Scene/stage_boss.tscn","0.0")
