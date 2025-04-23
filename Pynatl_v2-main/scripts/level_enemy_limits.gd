extends Area2D

# MAkes the enemies turn around when colliding, they ignore it if they are on chase

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.turn_around()
