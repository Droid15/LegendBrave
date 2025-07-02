extends HBoxContainer

@export var stats: Stats

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var score_layer: Label = $"../Score"
@onready var skey: TextureRect = $Skey
@onready var skill_layer: TextureRect = $SkillLayer
@onready var skill_count: Label = $SkillLayer/Skill_count


func _ready() -> void:
	if not stats:
		stats = SceneMaster.stats
	stats.health_changed.connect(update_health)
	update_health()
	
	stats.score_changed.connect(update_score)
	update_score()
	
	stats.stage_key_changed.connect(update_stage_key_layer)
	update_stage_key_layer()
	
	stats.skill_changed.connect(undate_skill_layer)
	undate_skill_layer()
	
func  update_health() -> void:
	var percentage := stats.health / float(stats.max_health)
	health_bar.value = percentage
	
func  update_score() -> void:
	score_layer.text = "Score: " + str(stats.score)
	
func update_stage_key_layer() -> void:
	skey.visible = SceneMaster.stats.stageKey

func undate_skill_layer() -> void:
	skill_layer.visible = stats.skill>0
	skill_count.text = "x "+str(stats.skill)
