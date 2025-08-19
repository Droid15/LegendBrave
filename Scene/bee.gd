extends Enemy

enum State {
	FLY,
	HIT,
	ATTACK,
	DYING
}

var pending_damage: Damage
const KNOCKBACK_AMOUNT := 300.0

#玩家位置
var player_position:Vector2

#蜜蜂飞行速度
var bee_speed := 100
const max_bee_speed := 200
#蜜蜂咬玩家的位置偏移
var offset := 5 

@onready var calm_down_timer: Timer = $CalmDownTimer
	
func _ready() -> void:
	#预设血量
	stats.health = 1

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.FLY:
			SceneMaster.player_pos.y = SceneMaster.player_pos.y - 26
			if SceneMaster.player_pos.x > position.x:
				direction = Direction.RIGHT
				offset = -5
			else:
				direction = Direction.LEFT
				offset = 5
			#靠近玩家就加速
			if abs(SceneMaster.player_pos.x - position.x)<66 and abs(SceneMaster.player_pos.y-position.y)<60:
				bee_speed = max_bee_speed
			global_position = global_position.move_toward(
				Vector2(SceneMaster.player_pos.x + offset, SceneMaster.player_pos.y), 
				bee_speed * delta
			)
		State.ATTACK:
			pass
	#animation_player.play("fly")
func transition_state(form: State, to: State) -> void:
	print("bee状态 %s" % to)
	match to:
		State.FLY:
			animation_player.play("fly")
		State.HIT:
			animation_player.play("hit")
			stats.health -= pending_damage.amount
			#受击方向
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUNT
			if dir.x > 0:
				direction = Direction.LEFT
			else:
				direction = Direction.RIGHT
			#被打击音效
			#damage_3.play()
			pending_damage = null
		State.ATTACK:
			animation_player.play("attack")
		State.DYING:
			animation_player.play("die")
			
func get_next_state(state: State) -> int:
	#血量为0，死亡
	if stats.health == 0:
		return StateMachin.KEEP_CURRENT if state==State.DYING else State.DYING
		
	if pending_damage:
		#print(stats.health)
		return State.HIT

	return State.FLY


func _on_hurtbox_hurt(hitbox: Variant) -> void:
	print("蜜蜂受伤")
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner


func _on_calm_down_timer_timeout() -> void:
	print("冷静时间结束")
