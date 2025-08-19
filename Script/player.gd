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
	DYING,
	SKILL
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

#技能时间
@export var skill_time := false

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false
var pending_damage: Damage

#记录跌落距离
#var fall_step := 0

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
	if SceneMaster.stats.health == 0:
		#print("死亡时不能操作")
		return 
	#监听技能释放
	if event.is_action_pressed("skill") and skill_time==false:
		if use_skill():
			skill_time = true
			SceneMaster.bee_await = true
			await get_tree().create_timer(2).timeout
			skill_time = false
			
			await get_tree().create_timer(3).timeout
			SceneMaster.bee_await = false
			
	if skill_time:
		print("技能释放时间，禁止其他输入")
		return
		
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
	
	#技能震动
	if skill_time:
		SceneMaster.quake(2, delta)
		
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
			
		State.HURT, State.DYING, State.SKILL:
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
	skill_reset()
	
func get_next_state(state: State) -> State:
	
	#站在地上不是掉落状态, 技能状态
	if state in GROUND_STATES and is_on_floor() and skill_time:
		return State.SKILL
		
	#判断应该坠落的状态
	if state in GROUND_STATES and not is_on_floor():
		#fall_step = 0
		
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
			#fall_step += 1
			if is_on_floor():
				#跌落扣血
				#if fall_step > 50:
					#_on_hurtbox_hurt(hit_box)
				#fall_step = 0
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
		State.SKILL:
			if not skill_time:
				return State.IDLE
				
	return StateMachin.KEEP_CURRENT

func transition_state(form: State, to: State) -> void:
	if form == State.RUNING:
		walk.stop()
	match to:
		State.IDLE:
			animation_player.play("idle")
			
		State.RUNING:
			animation_player.play("runing")
			if walk.finished:
				walk.play()
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
		
		State.SKILL:
			animation_player.play("skill")
			
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
	stats.score = 0
	
func skill_reset() -> void:
	stats.skill = 0
	
#使用技能
func use_skill() -> bool:
	if stats.skill==0:
		print("没有技能点")
		return false
	invincible_timer.start()
	stats.skill -= 1
	var all_enemy = get_tree().current_scene.find_children("Enemy*")
	#var camera = get_tree().current_scene.find_child("Camera2D")
	for enemy in all_enemy:
		#if SceneMaster.is_node_visible_in_camera(enemy, camera):
		if SceneMaster.is_on_screen(enemy):
			if enemy.stats and enemy.stats.health:
				enemy.stats.health -= 3
	$Skill_HumanCharge2.play()
	return true
