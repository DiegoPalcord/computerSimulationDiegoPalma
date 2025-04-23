extends CharacterBody2D


const SPEED = 800.0

var power = 10

func _physics_process(delta):
	position += velocity * delta

func setup(dir:Vector2):
	velocity = dir * SPEED

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(power)


func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("queue_free")
