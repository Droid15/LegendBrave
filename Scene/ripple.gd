extends Node2D

# 定义动画类型枚举
enum ANIM_TYPE {SIMPLE_BOB, SCANLINE, WAVE, DISSOLVE, PIXEL_GLITCH, FLICKER, ROTATION, COLOR_CYCLE}
var current_anim = ANIM_TYPE.SIMPLE_BOB

# 动画参数
var time = 0.0
var color_cycle_speed = 2.0
var wave_speed = 2.0
var wave_amplitude = 0.02
var rotation_speed = 0.5
var flicker_rate = 8.0
var pixel_glitch_intensity = 0.05

# 精灵引用
@onready var sprite: Sprite2D = $Sprite2D
#@onready var anim_label = $AnimationLabel
#@onready var instructions = $Instructions


func _ready():
	
	# 设置初始材质
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = preload("res://pixel_animations.gdshader")
	#update_animation_label()

func _physics_process(delta: float) -> void:
	time += delta
	
	# 更新动画参数
	match current_anim:
		ANIM_TYPE.SIMPLE_BOB:
			sprite.position.y = 10 + sin(time * 3) * 5
			sprite.material.set_shader_parameter("effect_intensity", 0.0)
		
		ANIM_TYPE.SCANLINE:
			sprite.position.y = 10
			sprite.material.set_shader_parameter("effect_intensity", 1.0)
			sprite.material.set_shader_parameter("time", time)
			sprite.material.set_shader_parameter("effect_type", 0)
		
		ANIM_TYPE.WAVE:
			sprite.position.y = 10
			sprite.material.set_shader_parameter("effect_intensity", 1.0)
			sprite.material.set_shader_parameter("time", time * wave_speed)
			sprite.material.set_shader_parameter("wave_amp", wave_amplitude)
			sprite.material.set_shader_parameter("effect_type", 1)
		
		ANIM_TYPE.DISSOLVE:
			sprite.position.y = 10
			sprite.material.set_shader_parameter("effect_intensity", 1.0)
			sprite.material.set_shader_parameter("time", time)
			sprite.material.set_shader_parameter("effect_type", 2)
		
		ANIM_TYPE.PIXEL_GLITCH:
			sprite.position.y = 10
			sprite.material.set_shader_parameter("effect_intensity", 1.0)
			sprite.material.set_shader_parameter("time", time * 5)
			sprite.material.set_shader_parameter("glitch_intensity", pixel_glitch_intensity)
			sprite.material.set_shader_parameter("effect_type", 3)
		
		ANIM_TYPE.FLICKER:
			sprite.position.y = 10
			sprite.material.set_shader_parameter("effect_intensity", 1.0)
			sprite.material.set_shader_parameter("time", time * flicker_rate)
			sprite.material.set_shader_parameter("effect_type", 4)
		
		ANIM_TYPE.ROTATION:
			sprite.position.y = 10
			sprite.rotation = sin(time * rotation_speed) * 0.1
			sprite.material.set_shader_parameter("effect_intensity", 0.0)
		
		ANIM_TYPE.COLOR_CYCLE:
			sprite.position.y = 10
			sprite.material.set_shader_parameter("effect_intensity", 1.0)
			sprite.material.set_shader_parameter("time", time * color_cycle_speed)
			sprite.material.set_shader_parameter("effect_type", 5)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# 循环切换动画类型
			current_anim = wrapi(current_anim + 1, 0, ANIM_TYPE.size())
			#update_animation_label()
		
		# 调整参数
		if event.keycode == KEY_UP:
			match current_anim:
				ANIM_TYPE.WAVE:
					wave_amplitude = min(wave_amplitude + 0.005, 0.1)
				ANIM_TYPE.COLOR_CYCLE:
					color_cycle_speed += 0.5
				ANIM_TYPE.PIXEL_GLITCH:
					pixel_glitch_intensity = min(pixel_glitch_intensity + 0.01, 0.2)
		
		if event.keycode == KEY_DOWN:
			match current_anim:
				ANIM_TYPE.WAVE:
					wave_amplitude = max(wave_amplitude - 0.005, 0.01)
				ANIM_TYPE.COLOR_CYCLE:
					color_cycle_speed = max(color_cycle_speed - 0.5, 0.5)
				ANIM_TYPE.PIXEL_GLITCH:
					pixel_glitch_intensity = max(pixel_glitch_intensity - 0.01, 0.01)

func update_animation_label():
	var anim_names = [
		"简单浮动", 
		"扫描线效果", 
		"波浪扭曲", 
		"溶解效果", 
		"像素故障", 
		"闪烁效果", 
		"旋转动画", 
		"颜色循环"
	]
	#anim_label.text = anim_names[current_anim]
