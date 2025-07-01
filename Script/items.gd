extends Area2D
@onready var get_item_audio: AudioStreamPlayer2D = $getItemAudio

var set_key_name:String = ""

func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	
	#打开mask第2层（player层）
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_enterd)

func _physics_process(delta: float) -> void:
	modulate.a = sin(Time.get_ticks_msec()/168) * 0.5 + 0.5

#捡道具
func _on_body_enterd(body: Player) -> void:
	SceneMaster.human_charge_1.play()
	
	if set_key_name == "Potion_v1":
		SceneMaster.stats.health += 1
		SceneMaster.stats.score += 1
		
	if set_key_name == "Potion_v2":
		SceneMaster.stats.health += 2
		SceneMaster.stats.score += 2
		
	if set_key_name == "Coin_v1":
		SceneMaster.stats.score += 2
		
	if set_key_name == "Coin_v2":
		SceneMaster.stats.score += 10
		
	if set_key_name == "Key":
		#print("吃到钥匙")
		SceneMaster.stats.stageKey = true
		
	set_key_name = ""
	queue_free()
	
	
