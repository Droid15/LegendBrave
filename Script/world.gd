extends Node2D
@onready var tile_map: TileMapLayer = $TileMap
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player

func  _ready() -> void:
	var used := tile_map.get_used_rect().grow(-1) #grow-1为相机视角缩一格
	var tile_set := tile_map.tile_set.tile_size
	
	#限制相机的上下左右视角
	camera_2d.limit_top = used.position.y * tile_set.y
	camera_2d.limit_right = used.end.x * tile_set.x
	camera_2d.limit_bottom = used.end.y * tile_set.y
	camera_2d.limit_left = used.position.x * tile_set.x
	createDefaultItem()
	
func createDefaultItem() -> void:
	var v := Vector2(51, -100)
	SceneMaster.droppedItem(v, "Potion_v1")
