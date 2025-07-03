extends Node2D

@onready var timer: Timer = $Timer
@onready var honeycomb: Area2D = $honeycomb

#是否出现蜜蜂窝
var show_honeycomb: = false

func _ready() -> void:
	SceneMaster.color_rect.color.a = 0
	
#倒计时结束就生成一只蜜蜂
func _on_timer_timeout():
	if show_honeycomb:
		SceneMaster.spawn_bee(honeycomb.position)
