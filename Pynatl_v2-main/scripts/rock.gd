extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurt_box = $Area2D
@onready var particles_1 = $CPUParticles2D2
@onready var particles_2 = $CPUParticles2D3
@onready var timer_blast = $BlastTimer
@onready var timer_destroy = $DestroyTimer
@onready var falling_timer = $FallingTimer
@onready var crushing_dust_1 = $CrushingDust/CPUParticles2D2
@onready var crushing_dust_2 = $CrushingDust/CPUParticles2D
@onready var falling_dust = $CPUParticles2D
@onready var falling_dust_2 = $CPUParticles2D4

var power = 20
var rock_shard = preload("res://scenes/entities/rock_shard.tscn")

#Type 1 are the falling ones, type 0 are the ones that are crushed
@export var type:int = 0
#If true makes the rock fall
var falling = false

func _ready():
	# Initial config (Yeah I know that is the definition of the function ready already)
	crushing_dust_1.set_emitting(false)
	crushing_dust_2.set_emitting(false)
	if type == 0:
		timer_blast.start()
	else:
		falling_timer.start()
		falling_dust.set_emitting(true)
		falling_dust_2.set_emitting(true)
	animated_sprite.scale = Vector2(0.1, 0.1)  # Starts the sprite small
	start_scale_animation()

func setup(type_received):
	type = type_received
		

func start_scale_animation():
	# Create a tween to handle the growing to 1 scale animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)  # Easing so it doesn't look janky
	tween.set_trans(Tween.TRANS_BACK)  # Elastic effect (for more visuals)
	
	# Play the animation tween
	tween.tween_property(animated_sprite, "scale", Vector2(1, 1), 0.5)
 
func blast():
	crushing_dust_1.set_emitting(true)
	crushing_dust_2.set_emitting(true)
	animated_sprite.play("blast")
	# Spawn rock shards in a radius
	var radius = 50
	var speed = 300
	var amount = 16
	for i in range(amount):
		var angle = i * (2 * PI / amount)
		var direction = Vector2(cos(angle), sin(angle))
		
		var projectile = rock_shard.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position + direction * radius
		
		# Set up movement of the entity
		if projectile.has_method("setup"):
			projectile.setup(direction)
		
		# Rotate the sprite
		if projectile.has_node("AnimatedSprite2D"):
			projectile.get_node("AnimatedSprite2D").rotation = direction.angle()

func destroy():
	call_deferred("queue_free")

func _physics_process(delta):
	if falling:
		velocity += get_gravity() * 2 * delta
	move_and_slide()


func _on_blast_timer_timeout():
	blast()

func _on_destroy_timer_timeout():
	destroy()


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(power)


func _on_falling_timer_timeout() -> void:
	# This timer allows the dust to fall to tell the player where the rock is going to fall
	falling = true
