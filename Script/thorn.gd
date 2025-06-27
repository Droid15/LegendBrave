extends Area2D

func _init() -> void:
	body_entered.connect(hurt_palyer)

func hurt_palyer(player: Player):
	print("金科刺秦王")
	player._on_hurtbox_hurt(player.hit_box)
