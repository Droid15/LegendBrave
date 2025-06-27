class_name StateMachin
extends Node
const KEEP_CURRENT := -1

#抽象状态机

var current_state: int = -1:
	set(v):
		#transition_state 自定义转换函数
		owner.transition_state(current_state, v)
		current_state = v
		state_time = 0
		
var state_time: float

func _ready() -> void:
	await  owner.ready
	current_state = 0

func _physics_process(delta: float) -> void:
	var loop_guard: int = 0
	#每时每刻检测状态情况
	while true:
		#loop_guard += 1
		#if loop_guard > 60:
			#print("状态机死循环 %s" % current_state)
			#break
		var next := owner.get_next_state(current_state) as int
		#当前状态就是要转换的状态就直接break
		if next == current_state:
			break
		if next == KEEP_CURRENT:
			break
		current_state = next
	owner.tick_physics(current_state, delta)
	state_time += delta
