extends Node2D

@onready var timer: Timer = $Timer
@export var bee_tsc:PackedScene
@onready var honeycomb: Area2D = $honeycomb

#是否出现蜜蜂窝
var show_honeycomb: = false

func _ready() -> void:
	SceneMaster.color_rect.color.a = 0
	
func _on_timer_timeout():
	if show_honeycomb:
		var bee := bee_tsc.instantiate()
		bee.position = honeycomb.position
		bee.name = "Enemybee"+ str(randf_range(1,9999999))
		get_tree().current_scene.add_child(bee)
