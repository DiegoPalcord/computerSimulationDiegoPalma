extends CharacterBody2D

var amount: int = randi_range(5,10)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		GameMaster.change_cocoa(amount, 0)
		var ui = get_tree().get_first_node_in_group("UI")
		ui.update_labels()
		call_deferred("queue_free")
