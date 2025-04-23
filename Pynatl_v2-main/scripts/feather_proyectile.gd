extends CharacterBody2D

var speed: int = 1200
var direction: Vector2 = Vector2.RIGHT
var power: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()


func _on_timer_timeout():
	call_deferred("queue_free")


func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy"):
		body.hurt(power)
