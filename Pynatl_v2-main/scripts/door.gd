extends Node2D

@export var destined_level: String
@export var destined_door_id: int
@export var door_id: int

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		# A small timer to prevent sudden changes
		await get_tree().create_timer(0.1).timeout
		SceneManager.change_level(destined_level, destined_door_id)
