extends Node2D
@onready var enemy_boss_bee: CharacterBody2D = $EnemyBeeBoss

@onready var timer: Timer = $Timer

var reay_time := 3
var shuld_attack := false

func _ready() -> void:
	enemy_boss_bee.find_child("AnimationPlayer").play('fly')
	timer.wait_time = reay_time
	timer.start()
	
func _physics_process(delta: float) -> void:
	if randf()>0.6 and timer.wait_time <= 2:
		enemy_boss_bee.player_pos_tmp.x = SceneMaster.player_pos.x
		enemy_boss_bee.player_pos_tmp.y = SceneMaster.player_pos.y - 26 
		
func _on_timer_timeout() -> void:
	print("攻击...")
	shuld_attack = !shuld_attack
	enemy_boss_bee.shuld_attack = shuld_attack
	if enemy_boss_bee.bee_speed < enemy_boss_bee.max_bee_speed:
		enemy_boss_bee.bee_speed += 10
		
	if timer.wait_time > 2:
		timer.wait_time -= 0.1
		
	SceneMaster.player_pos.y = SceneMaster.player_pos.y - 26
	enemy_boss_bee.player_pos_tmp = SceneMaster.player_pos
	
	if shuld_attack:
		print("攻击结束应该回到待机点")
		enemy_boss_bee.position = enemy_boss_bee.boss_default_pos

func boss_attack() ->void:
	shuld_attack = false
