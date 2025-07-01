class_name Player
extends CharacterBody2D

enum State {
	IDLE,
	RUNING,
	JUMP,
	FALL,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
	HURT,
	DYING
}

#站在地板上的动作组
const GROUND_STATES := [State.IDLE, State.RUNING, State.ATTACK_1, State.ATTACK_2, State.ATTACK_3]
const RUN_SPEED := 120.0
const FLOOR_ACCELERATION: = RUN_SPEED / 0.2
const AIR_ACCELERATION: = RUN_SPEED / 0.02
const JUMP_VELOCITY: = -320.0
const KNOCKBACK_AMOUNT := 312.0
#是否连击
@export var can_combo := false

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false
var pending_damage: Damage

#记录跌落距离
var fall_step := 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var stats: Node = SceneMaster.stats

#无敌时间
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var attack_1: AudioStreamPlayer2D = $Attack1
@onready var jump: AudioStreamPlayer2D = $Jump
@onready var walk: AudioStreamPlayer2D = $Walk
@onready var score_layer: Label = $CanvasLayer/Score
@onready var human_charge_1: AudioStreamPlayer = $"08HumanCharge1"
@onready var man_hurt: AudioStreamPlayer = $ManHurt
@onready var camera_2d: Camera2D = $Camera2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		if velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
			
	if event.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			
	if event.is_action_pressed("attack") and can_combo:
		is_combo_requested = true
	#翻转攻击碰撞区域
	if event.is_action_pressed("move_left"):
		hit_box.scale.x = -1
		
	if event.is_action_pressed("move_right"):
		hit_box.scale.x = 1
func tick_physics(state: State, delta: float) -> void:
	#更新实时玩家坐标
	SceneMaster.player_pos = position
	
	#处于无敌时间，身体闪烁效果
	if invincible_timer.time_left >0:
		modulate.a = sin(Time.get_ticks_msec()/20) * 0.5 + 0.5
	else:
		modulate.a = 1
	#跌落死亡
	if position.y > 380:
		stats.health -= 1
		
	match state:
		State.IDLE:
			move(delta)
			
		State.RUNING:
			move(delta)
		State.JUMP:
			move(delta)
			
		State.FALL:
			move(delta)
			#print("玩家高度位置 %s" % position.y)
		State.ATTACK_1,State.ATTACK_3,State.ATTACK_3:
			stand(gravity, delta)
			
		State.HURT, State.DYING:
			stand(gravity, delta)
			
	is_first_tick = false
		
func move(delta: float) ->void:
	var diraction := Input.get_axis("move_left", "move_right")
	#用move_toward给跑步加惯性
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, diraction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta

	#有输入的时候按方向来翻转角色朝向
	if not is_zero_approx(diraction):
		sprite_2d.flip_h = diraction < 0
	move_and_slide()
	
func stand(gravity_s: float, delta: float) -> void:
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.y += gravity_s * delta
	move_and_slide()

#payer死亡
func die() -> void:
	#重载当前游戏场景
	get_tree().reload_current_scene()
	health_reset()
	score_reset()
	
func get_next_state(state: State) -> State:
	
	#判断应该坠落的状态
	if state in GROUND_STATES and not is_on_floor():
		fall_step = 0
		
		return State.FALL
	
		#血量为0，死亡
	if stats.health == 0:
		return StateMachin.KEEP_CURRENT if state==State.DYING else State.DYING
		
	#受伤
	if pending_damage:
		return State.HURT
		
	var diraction := Input.get_axis("move_left", "move_right")
	var is_still := is_zero_approx(diraction) and is_zero_approx(velocity.x)
	match state:
		State.IDLE:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1
			if not is_still:
				return State.RUNING
				
		State.RUNING:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1
			if is_still:
				return State.IDLE
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
				
		State.FALL:
			fall_step += 1
			if is_on_floor():
				#跌落扣血
				if fall_step > 50:
					_on_hurtbox_hurt(hit_box)
				fall_step = 0
				return State.IDLE if is_still else State.RUNING
		State.ATTACK_1:
			if not animation_player.is_playing():
				return State.ATTACK_2 if is_combo_requested else State.IDLE
				
		State.ATTACK_2:
			if not animation_player.is_playing():
				return State.ATTACK_3 if is_combo_requested else State.IDLE
				
		State.ATTACK_3:
			if not animation_player.is_playing():
				return State.IDLE
		State.HURT:
			if not animation_player.is_playing():
				return State.IDLE
	return StateMachin.KEEP_CURRENT

func transition_state(form: State, to: State) -> void:
	match to:
		State.IDLE:
			animation_player.play("idle")
			
		State.RUNING:
			animation_player.play("runing")
		State.JUMP:
			animation_player.play("jump")
			jump.play()
			velocity.y = JUMP_VELOCITY
			
		State.FALL:
			animation_player.play("jump")
			
		State.ATTACK_1:
			animation_player.play("attack_1")
			attack_1.play()
			is_combo_requested = false
			
		State.ATTACK_2:
			animation_player.play("attack_2")
			is_combo_requested = false
			
		State.ATTACK_3:
			animation_player.play("attack_3")
			is_combo_requested = false
		State.HURT:
			animation_player.play("hurt")
			#print("玩家被打")
			stats.health -= pending_damage.amount
			#受击方向
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUNT
				
			pending_damage = null
			invincible_timer.start()
			man_hurt.play()
		State.DYING:
			animation_player.play("die")
			invincible_timer.stop()
			$GameOver.play()
	is_first_tick = true


func _on_hurtbox_hurt(hitbox: HitBox) -> void:
	var enemy_bee: = hitbox.find_parent("Enemybee*")
	if enemy_bee:
		print("payer受伤了 %s 打的" % enemy_bee.name)
		enemy_bee.queue_free()
		
	#无敌计时器未结束
	if invincible_timer.time_left > 0:
		return
		
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
func health_add():
	stats.health += 1
	human_charge_1.play()
	
func health_reset() -> void:
	stats.health = 3
	
func score_reset() -> void:
	stats.score = 0;
