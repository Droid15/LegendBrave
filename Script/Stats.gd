class_name Stats
extends Node
signal health_changed
signal score_changed
signal stage_key_changed
signal skill_changed

@export var max_health: int = 3
@export var min_score: int = 0
@export var max_skill: int = 3
@export var min_skill: int = 0

@onready var health: int = max_health:
	set(v):
		v = clampi(v, 0, max_health)
		if health == v:
			return
		health = v
		health_changed.emit()
		
@onready var score: int = min_score:
	set(v):
		v = clamp(v, min_score, 9999)
		if score == v:
			return 
		score = v
		score_changed.emit()
		
#设置过关钥匙
@onready var stageKey: bool:
	set(v):
		stageKey = v
		stage_key_changed.emit()
		
#技能次数变化
@onready var skill: int = 1:
	set(v):
		v = clampi(v, 0, max_skill)
		if skill == v:
			return
		skill = v
		skill_changed.emit()
