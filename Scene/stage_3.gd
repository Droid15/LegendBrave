extends Node2D
@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var timer: Timer = $Timer
var show_enemy_boar := false

func _ready() -> void:
	bgm.play()


func _on_bgm_finished() -> void:
	print(name+"节点bgm播放结束")


func _on_timer_timeout() -> void:
	if show_enemy_boar:
		var pos := Vector2(3226,345)
		SceneMaster.spawn_bee(pos)

#看门野猪进入摄像机视野范围
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	show_enemy_boar = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	show_enemy_boar = false

#看门野猪被回收
func _on_visible_on_screen_notifier_2d_tree_exited() -> void:
	show_enemy_boar = false
