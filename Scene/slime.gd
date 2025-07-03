extends Enemy

enum State {
	WALK,
	HURT,
	DYING
}

var pending_damage: Damage
const KNOCKBACK_AMOUNT := 300.0

#玩家位置
var player_position:Vector2

#蜜蜂飞行速度
var bee_speed := 100
const max_bee_speed := 200

@onready var calm_down_timer: Timer = $CalmDownTimer
@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var slime_death: AudioStreamPlayer2D = $SlimeDeath
	
func _ready() -> void:
	#预设血量
	stats.health = 1

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.WALK:
			SceneMaster.player_pos.y = SceneMaster.player_pos.y - 26
				
			if wall_checker.is_colliding():
				print("撞墙转向")
				direction *= -1
				
			move(max_speed / 2, delta)
			
		State.HURT:
			move(0, delta)
		
	#animation_player.play("fly")
func transition_state(form: State, to: State) -> void:
	print("bee状态 %s" % to)
	match to:
		State.WALK:
			animation_player.play("walk")
			
		State.HURT:
			animation_player.play("hurt")
			stats.health -= 1
		State.DYING:
			animation_player.play("die")
			slime_death.play()
			
func get_next_state(state: State) -> int:
	#血量为0，死亡
	if stats.health == 0:
		return StateMachin.KEEP_CURRENT if state==State.DYING else State.DYING
		
	if pending_damage:
		#print(stats.health)
		return State.HURT

	return State.WALK
	
func move(speed: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	velocity.y = gravity * 15 * delta
	move_and_slide()
	
func _on_hurtbox_hurt(hitbox: Variant) -> void:
	print("受伤")
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
	
	#await  get_tree().create_timer(0.6).timeout
	#queue_free()

func _on_calm_down_timer_timeout() -> void:
	print("冷静时间结束")
