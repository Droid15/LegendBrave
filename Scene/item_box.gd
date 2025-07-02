extends Area2D

@export var set_item := ""
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _init() -> void:
	body_entered.connect(open_item_box)
	
func open_item_box(body: Player) -> void:
	print("%s 开宝箱" % body.name)
	animation_player.play("open_box")
	SceneMaster.droppedItem(position, set_item)
	collision_mask = 0
	await  get_tree().create_timer(2).timeout
	queue_free()
