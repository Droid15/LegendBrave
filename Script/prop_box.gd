class_name PropBox
#静止的奖励道具
extends Area2D
@onready var stats: Stats = $Stats
signal health_recharge(ddd:Area2D)

func _init() -> void:
	#body_entered.connect(player_health_recharge)
	body_entered.emit("health_recharge_over")
	
func player_health_recharge(ddd: Area2D) -> void:
	print("来加血")
	stats.health = 3
	
