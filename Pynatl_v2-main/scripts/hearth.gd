extends CharacterBody2D

@export var flag: int

var random: int =randi_range(0,2)
var amount: Array = [20,20,20] # If i want to make it random later

func _ready():
	if GameMaster.hearth_flags[flag] == true:
		call_deferred("queue_free")

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		GameMaster.change_max_hp(amount[random], 0, flag)
		call_deferred("queue_free")
