extends CharacterBody2D

@export var flag: int = 0

var amount: int = 5

func _ready():
	if GameMaster.obsidian_flags[flag] == true:
		call_deferred("queue_free")

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		GameMaster.change_damage(amount, 0, flag)
		print("new attack: ", GameMaster.player_data.damage)
		call_deferred("queue_free")
