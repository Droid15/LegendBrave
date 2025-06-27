extends Node
@onready var color_rect: ColorRect = $ColorRect
@onready var stats: Stats = $Stats
@export var items_tsc: PackedScene
@onready var human_charge_1: AudioStreamPlayer = $AudioNode/HumanCharge1

#玩家分数
var score := 0

#物品掉落概率
var fall_rate := 1.0

#地震恢复速度
var recover_speed := 16.0

func _ready() -> void:
	color_rect.color.a = 0

func _process(delta: float) -> void:
	#f12地震
	if Input.is_action_pressed("f12"):
		quake(4, delta)
	
func _physics_process(delta: float) -> void:
	
	#F9跳关
	#if OS.is_debug_build():
	if not OS.has_feature("template"):
		if Input.is_action_just_pressed("next_stage"):
			print("当前是debug模式可以跳关")
			var arr := ["world.tscn", "stage_2.tscn", "stage_3.tscn"]
			var now_stage = get_tree().current_scene.scene_file_path
			print(now_stage)
			
			var i := 0
			for name in arr:
				i += 1
				if "res://Scene/"+name == now_stage:
					break
			if i < arr.size():
				change_scene("res://Scene/"+arr[i],"0,0")
			else:
				change_scene("res://Scene/"+arr[0],"0,0")
	else:
		print("正式模式无法跳关")

#全局场景管理
func change_scene(path: String, entry_point: String):
	#print("切换场景后的玩家位置%s" % entry_point)
	var tree := get_tree()
	#tree.paused = true
	
	#补间动画
	var tween := create_tween()
	#print("转场debug")
	tween.tween_property(color_rect, "color:a", 1, 0.5)
	await tween.finished
	
	#tree.change_scene_to_file.(path) #4.2前
	tree.change_scene_to_file.bind(path).call_deferred()
	#等待1帧
	#print("等待1帧")
	await tree.tree_changed
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0, 0.2)
	#print(color_rect.color.a)
	
#物品掉落
func droppedItem(position: Vector2, item_name := "") -> void:
	if randf() <= fall_rate and items_tsc:
		var items =  items_tsc.instantiate()
		items.position = position
		items.position.y -= 16
		get_tree().current_scene.add_child(items)
		var set_item: Node
		
		#手动指定掉落物品
		if item_name != "":
			var s_item := items.get_node("ItemBox").get_node(item_name)
			if s_item:
				set_item = s_item
		else:
			#随机掉落物品
			set_item = items.get_node("ItemBox").get_children().pick_random()
			if stats.stageKey and set_item.name=="Key":
				set_item = items.get_node("ItemBox").get_node("Potion_v1")
				
		set_item.visible = true
		items.set_key_name = set_item.name
		print("物品掉落:", set_item.name)
		
#相机震动
func quake(rate: float, delta: float) -> void:
	if rate <=0 :
		return
	var camera := get_tree().current_scene.find_child("Camera2D")
	if camera:
		camera.offset = Vector2(
			randf_range(-rate, rate),
			randf_range(-rate, rate)
		)
		rate = move_toward(rate, 0, recover_speed * delta)
