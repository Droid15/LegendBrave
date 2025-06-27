class_name Prop

extends Sprite2D
signal health_recharge_over

#func _init() -> void:
	#collision_layer

func _physics_process(delta: float) -> void:
	#闪烁
	modulate.a = sin(Time.get_ticks_msec()/200) * 0.5 + 0.5
	
