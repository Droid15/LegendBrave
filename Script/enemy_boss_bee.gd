#extends Enemy
extends Node2D
@onready var player: Player = $"../Player"
@onready var timer: Timer = $"../Timer"
@onready var stats: Stats = $Stats
@onready var atk_sword_3: AudioStreamPlayer = $"17OrcAtkSword3"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"

var boss_default_pos:Vector2
var health := 12
#蜜蜂咬玩家的位置偏移
var offset := 5 
const max_bee_speed := 500
var bee_speed := 400
var shuld_attack := false
enum State {
	FLY,
	HIT,
	ATTACK,
	DYING
}
#敌人面向
enum Direction {
	LEFT = -1,
	RIGHT = +1,
}
var player_pos_tmp:Vector2
var pending_damage: Damage
var flash := false

func _ready() -> void:
	boss_default_pos = position
	stats.max_health = health
	stats.health = health
	
func _physics_process(delta: float) -> void:
	if flash:
		boss_flash()
		
	if not shuld_attack:
		go_home(delta)
		return
		
	#SceneMaster.player_pos.y = SceneMaster.player_pos.y - 26
	if SceneMaster.player_pos.x > position.x:
		scale.x = Direction.LEFT
		offset = -5
	else:
		scale.x = Direction.RIGHT
		offset = 5
	
	global_position = global_position.move_toward(
		Vector2(player_pos_tmp.x + offset, player_pos_tmp.y), 
		bee_speed * delta
	)
	
func go_home(delta: float) -> void:
	global_position = global_position.move_toward(
		Vector2(boss_default_pos.x, boss_default_pos.y), 
		max_bee_speed * delta
	)

#boss闪烁
func boss_flash() -> void:
	modulate.a = sin(Time.get_ticks_msec()/160) * 0.5 + 0.5

func _on_hurtbox_hurt(hitbox: Variant) -> void:
	print("boss受伤")
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
	health -= 1
	stats.health -= 1
	atk_sword_3.play()
	#击退
	shuld_attack = false
	
	#闪烁
	flash = true
	await  get_tree().create_timer(1.5).timeout
	flash = false
	modulate.a = 1.0
	print("boss状态：",stats.health)
	if health<=0:
		print("boss死亡")
		timer.stop()
		SceneMaster.victory = true
		canvas_layer.show()
		player.animation_player.stop()
		queue_free()
