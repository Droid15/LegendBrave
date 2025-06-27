extends Node2D
@onready var bgm: AudioStreamPlayer2D = $BGM

func _ready() -> void:
	bgm.play()
