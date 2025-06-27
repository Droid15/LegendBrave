extends Area2D

func _init() -> void:
	body_entered.connect(enter_stage1)

func enter_stage1(player: Player) -> void:
	print("第1关")
	if SceneMaster.stats.stageKey==false :
		return 
	SceneMaster.stats.stageKey = false
	#SceneMaster.change_scene("res://world.tscn", "0.0")
	SceneMaster.change_scene("res://Scene/stage_3.tscn","0.0")
