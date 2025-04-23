extends CharacterBody2D

@export var flag: int

var random: int = randi_range(0,2)
var amount: Array = [2,3,5]

func ready():
	print("Feathers global pos:", global_position)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		GameMaster.change_feathers(amount[random], 0)
		print("Feathers: ",GameMaster.player_data.feathers)
		call_deferred("queue_free")


func _on_timer_timeout():
	call_deferred("queue_free")
