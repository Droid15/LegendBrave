extends Enemy

enum State {
	IDLE,
	WALK,
	RUN,
	HURT,
	FALL,
	DYING
}

var pending_damage: Damage
const KNOCKBACK_AMOUNT := 400.0

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var calm_down_timer: Timer = $CalmDownTimer

func  _ready() -> void:
	self.max_speed = 200.0
	
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE, State.HURT, State.DYING, State.FALL:
			move(0.0, delta)
		State.WALK:
			#前面有悬崖就转身
			if not floor_checker.is_colliding():
				direction *= -1
			move(max_speed / 3, delta)
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
			#if wall_checker.is_colliding():
				direction *= -1
			move(max_speed, delta)
			#玩家在野猪视野范围内就启动冷静时间（2.5s）
			if player_checker.is_colliding():
				calm_down_timer.start()

func get_next_state(state: State) -> int:
	#血量为0，死亡
	if stats.health == 0:
		return StateMachin.KEEP_CURRENT if state==State.DYING else State.DYING
	
	if not is_on_floor():
		#print("野猪不在地板上")
		return State.FALL
		
	#受伤
	if pending_damage:
		return State.HURT
		
	#视线看到玩家
	if player_checker.is_colliding():
		return State.RUN
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
		State.RUN:
			#冷静倒数时间结束就走
			if calm_down_timer.is_stopped():
				return State.WALK
		State.HURT:
			if not is_on_floor():
				return State.FALL
				
			if not animation_player.is_playing():
				return State.RUN
	return StateMachin.KEEP_CURRENT
	
func transition_state(form: State, to: State) -> void:
	if name == "Boar4":
		print("野猪4的状态：%s" % to)
	match to:
		State.IDLE:
			animation_player.play("idle")
			#遇到墙就转身
			if wall_checker.is_colliding():
				direction *= -1
		State.RUN:
			animation_player.play("run")
			#前面没有地板就转身
			if not floor_checker.is_colliding():
				#direction *= -1
				floor_checker.force_raycast_update()
				
		State.WALK:
			animation_player.play("walk")
		State.HURT:
			animation_player.play("hit")
			#print("野猪被打")
			stats.health -= pending_damage.amount
			#受击方向
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUNT
			if dir.x > 0:
				direction = Direction.LEFT
			else:
				direction = Direction.RIGHT
				
			pending_damage = null
		State.DYING:
			animation_player.play("die")
			
		State.FALL:
			animation_player.play("idle")
	

#野猪受伤
func _on_hurtbox_hurt(hitbox: HitBox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
