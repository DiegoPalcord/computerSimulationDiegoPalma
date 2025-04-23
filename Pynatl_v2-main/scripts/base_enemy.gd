extends CharacterBody2D

# Constants
const SPEED = 8000.0

# Node related variables
@onready var attack_area: Area2D = $Attack
@onready var player_near_area: Area2D = $PlayerNear
@onready var hurt_box: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var patrol_timer: Timer = $PatrolTimer
@onready var raycast_top: RayCast2D = $TopRay
@onready var raycast_center_top: RayCast2D = $TopCenterRay
@onready var raycast_center_bottom: RayCast2D = $BottomCenterRay
@onready var raycast_bottom: RayCast2D = $BottomRay
@onready var raycast_center: RayCast2D = $CenterRay
@onready var raycast_over: RayCast2D = $OverRay
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var death_timer: Timer = $DeathTimer

@onready var blood: CPUParticles2D = $Blood/CPUParticles2D
@onready var death: CPUParticles2D = $Death/CPUParticles2D

@onready var player = get_tree().get_first_node_in_group("Player")


var stats = {
	"health": 80,
	"contact_damage": 5,
	"attack_power": 15
}

var direction = 0
var facing_right = false
var is_ground_attack = false
var chasing = false
var state = 0

func _ready():
	attack_area.monitoring = false
	attack_area.visible = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var can_see_player = (
		raycast_bottom.is_colliding() and raycast_bottom.get_collider() == player or
		raycast_center_bottom.is_colliding() and raycast_center_bottom.get_collider() == player or
		raycast_center.is_colliding() and raycast_center.get_collider() == player or
		raycast_center_top.is_colliding() and raycast_center_top.get_collider() == player or
		raycast_top.is_colliding() and raycast_top.get_collider() == player or
		raycast_over.is_colliding() and raycast_over.get_collider() == player
	)

	if velocity.x != 0 and not is_ground_attack and is_on_floor():
		animated_sprite.play("Run")
	
	if can_see_player and not is_ground_attack:
		on_chase()
	else:
		chasing = false
	
	if direction and not is_ground_attack and is_on_floor():
		var current_speed = SPEED
		velocity.x = direction * current_speed * delta
		if direction == 1:
			animated_sprite.scale.x = abs(animated_sprite.scale.x)
			facing_right = true
			update_attack_areas_direction()
		elif direction == -1:
			animated_sprite.scale.x = -abs(animated_sprite.scale.x)
			facing_right = false
			update_attack_areas_direction()
		else:
			velocity.x = 0

	move_and_slide()

func patrol():
	if not chasing and not is_ground_attack:
		direction = randi_range(-1, 1)

func on_chase():
	chasing = true
	# We made it local because this one is a vector, not an integer
	var direction_local = (player.global_position - global_position).normalized()
	direction_local.y = 0
	velocity = direction_local * SPEED * get_physics_process_delta_time()
	move_and_slide()

func wind_up():
	is_ground_attack = true
	velocity.x = 0
	animated_sprite.play("Wind up")
	await animated_sprite.animation_finished
	attack()

func attack():
	attack_area.monitoring = true
	attack_area.visible = true
	animated_sprite.play("Attack")
	# Used await animated_sprite.animation_finished but worked buggy when interupted causing
	# the area damage to keep monitoring
	await get_tree().create_timer(0.75).timeout
	attack_area.monitoring = false
	attack_area.visible = false
	is_ground_attack = false

func hurt(damage):
	stats.health -= damage
	animation_player.play("hurt")
	blood.set_emitting(true)
	if stats.health <= 0 and state == 0:
		death.set_emitting(true)
		die()

func die():
	state = 1
	spawn("feathers")
	deactivate_entity()
	animated_sprite.play("Wind up", 0.7)
	death_timer.start()

func spawn(item:String):
	Drops.place_drops(item, global_position)

func update_attack_areas_direction():
	# Ajusting the scale of the Area2D nodes so they match to where the character is looking at
	if facing_right:
		attack_area.scale.x = abs(attack_area.scale.x)
		player_near_area.scale.x = abs(player_near_area.scale.x)
		hurt_box.scale.x = abs(hurt_box.scale.x)
		raycast_top.scale.x = abs(raycast_top.scale.x)
		raycast_center_top.scale.x = abs(raycast_center_top.scale.x)
		raycast_center.scale.x = abs(raycast_center.scale.x)
		raycast_center_bottom.scale.x = abs(raycast_center_bottom.scale.x)
		raycast_bottom.scale.x = abs(raycast_bottom.scale.x)
		raycast_over.scale.x = abs(raycast_over.scale.x)
	else:
		attack_area.scale.x = -abs(attack_area.scale.x)
		player_near_area.scale.x = -abs(player_near_area.scale.x)
		hurt_box.scale.x = -abs(hurt_box.scale.x)
		raycast_top.scale.x = -abs(raycast_top.scale.x)
		raycast_center_top.scale.x = -abs(raycast_center_top.scale.x)
		raycast_center.scale.x = -abs(raycast_center.scale.x)
		raycast_center_bottom.scale.x = -abs(raycast_center_bottom.scale.x)
		raycast_bottom.scale.x = -abs(raycast_bottom.scale.x)
		raycast_over.scale.x = -abs(raycast_over.scale.x)

func do_damage(body, power):
	if body.is_in_group("Player"):
		if body.has_method("hurt"):
			body.hurt(power)

func turn_around():
	if not chasing:
		direction *= -1 

# Deactivate everything exept the colissionbox and the animations
func deactivate_entity():
	attack_area.set_process(false)
	attack_area.set_physics_process(false)
	attack_area.monitoring = false
	attack_area.set_deferred("monitorable",false)
	
	player_near_area.set_process(false)
	player_near_area.set_physics_process(false)
	player_near_area.monitoring = false
	player_near_area.set_deferred("monitorable",false)
	
	hurt_box.set_process(false)
	hurt_box.set_physics_process(false)
	hurt_box.monitoring = false
	hurt_box.set_deferred("monitorable",false)
	
	hit_box.set_process(false)
	hit_box.set_physics_process(false)
	hit_box.monitoring = false
	hit_box.set_deferred("monitorable",false)
	
	patrol_timer.stop()

	raycast_top.enabled = false
	raycast_center_top.enabled = false
	raycast_center_bottom.enabled = false
	raycast_bottom.enabled = false
	raycast_center.enabled = false
	raycast_over.enabled = false
	# Halt any movemnt and frame check
	
	set_physics_process(false)

func _on_patrol_timer_timeout():
	patrol()

func _on_player_near_body_entered(body):
	await wind_up()
	attack()

func _on_hit_box_body_entered(body):
	do_damage(body, stats.contact_damage)

func _on_attack_body_entered(body):
	do_damage(body, stats.attack_power)

func _on_death_timer_timeout():
	death.set_emitting(false)
	call_deferred("queue_free")
