class_name Enemy
extends CharacterBody2D

#敌人面向
enum Direction {
	LEFT = -1,
	RIGHT = +1,
}

@export var direction := Direction.LEFT:
	set(v):
		direction = v
		#等待节点加载
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction
		
@export var max_speed := 150.0
@export var acceleration := 2000.0

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var graphics : Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machin: StateMachin = $StateMachin
@onready var stats: Stats = $Stats

func _ready() -> void:
	add_to_group("Enemy")

func move(speed: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	velocity.y = gravity * 15 * delta
	move_and_slide()

func die() -> void:
	#杀死敌人加分
	SceneMaster.stats.score += 5
	queue_free()
	
	#只剩一只野猪还没得到钥匙的时候固定掉钥匙
	if get_tree().current_scene.find_children("Enemy*").size()==1 and SceneMaster.stats.stageKey==false:
		SceneMaster.droppedItem(position, "Key")
	else:
		SceneMaster.droppedItem(position)
	
