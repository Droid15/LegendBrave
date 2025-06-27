extends HBoxContainer

@export var stats: Stats

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var score_layer: Label = $"../Score"
@onready var skey: TextureRect = $Skey

func _ready() -> void:
	if not stats:
		stats = SceneMaster.stats
	stats.health_changed.connect(update_health)
	update_health()
	
	stats.score_changed.connect(update_score)
	update_score()
	
	stats.stage_key_changed.connect(update_stage_key_layer)
	update_stage_key_layer()
	

func  update_health() -> void:
	var percentage := stats.health / float(stats.max_health)
	health_bar.value = percentage
	
func  update_score() -> void:
	score_layer.text = "Score: " + str(stats.score)
	
func update_stage_key_layer() -> void:
	skey.visible = SceneMaster.stats.stageKey
