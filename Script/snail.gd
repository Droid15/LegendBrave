extends Enemy

enum State {
	WALK,
	IDLE,
	#RUN,
	SHY,
	HURT,
	FALL,
	DYING
}

var pending_damage: Damage
const KNOCKBACK_AMOUNT := 512.0
var damage_limit := 0
var cooling := false

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var calm_down_timer: Timer = $CalmDownTimer
#@onready var human_damage_3: AudioStreamPlayer2D = $"11HumanDamage3"
@onready var damage_3: AudioStreamPlayer2D = $damage3

func _ready() -> void:
	name = "Enemysnail"

#站在地板上的动作组
const GROUND_STATES := [State.IDLE, State.SHY]
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE, State.HURT, State.DYING, State.FALL, State.SHY:
			move(0.0, delta)
		State.WALK:
			#前面有悬崖就转身
			if not floor_checker.is_colliding():
				direction *= -1
			move(max_speed / 3, delta)
				
func get_next_state(state: State) -> int:
	#血量为0，死亡
	if stats.health == 0:
		return StateMachin.KEEP_CURRENT if state==State.DYING else State.DYING
	#判断应该坠落的状态
	if not is_on_floor():
		return State.FALL
		
	if pending_damage:
		#print("damage debug....")
		damage_limit +=1
		if damage_limit > 60:
			damage_limit = 0
			#print("死循环了....%s" % damage_limit)
			return State.WALK
		return State.HURT
		
	#视线看到玩家
	if player_checker.is_colliding():
		return State.SHY
		
	match state:
		State.IDLE:
			#站两秒就走
			if state_machin.state_time > 2:
				return State.WALK
		State.WALK:
			#检测到有悬崖或者墙就站着不动
			#if wall_checker.is_colliding() or not floor_checker.is_colliding():
			if wall_checker.is_colliding():
				return State.IDLE
		State.SHY:
			#冷静倒数时间结束就走
			#if calm_down_timer.is_stopped():
				#return State.WALK
			if not player_checker.is_colliding():
				print("蜗牛羞,玩家不在视线....")
				if cooling and not calm_down_timer.is_stopped():
					return State.SHY
				cooling = true
				calm_down_timer.start()
				print("开始冷静")
			return State.WALK
		State.HURT:
			if not is_on_floor():
				return State.FALL
			if not animation_player.is_playing():
				return State.SHY
		State.FALL:
			if is_on_floor():
				return State.IDLE
			
	return StateMachin.KEEP_CURRENT
	
func transition_state(form: State, to: State) -> void:
	match to:
		State.IDLE:
			animation_player.play("idle")
			#遇到墙就转身
			if wall_checker.is_colliding():
				direction *= -1
		State.SHY:
			animation_player.play("shy")
			#前面没有地板就转身
			if not floor_checker.is_colliding():
				#direction *= -1
				floor_checker.force_raycast_update()
				
		State.WALK:
			animation_player.play("walk")
		State.HURT:
			animation_player.play("hit")
			#print("被打")
			stats.health -= pending_damage.amount
			#受击方向
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUNT
			if dir.x > 0:
				direction = Direction.LEFT
			else:
				direction = Direction.RIGHT
			#被打击音效
			damage_3.play()
			pending_damage = null
		State.DYING:
			animation_player.play("die")
			
		State.FALL:
			animation_player.stop()

#敌人受伤
func _on_hurtbox_hurt(hitbox: HitBox) -> void:
	print("受伤")
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner


func _on_calm_down_timer_timeout() -> void:
	cooling = false
	print("冷静结束......")
