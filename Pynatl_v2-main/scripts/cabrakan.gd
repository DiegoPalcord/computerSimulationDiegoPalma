extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var stomp_hit_box = $StompHitBox
@onready var leap_hit_box = $LeapHitBox
@onready var crush_hit_box = $CrushHitBox
@onready var active_hit_box = $ActiveHitBox
@onready var hurt_box = $HurtBox
@onready var range = $Range
@onready var range_2 = $Range2
@onready var attack_timer = $ActionTimer
@onready var rock_spawn_timer = $RockSpawnTimer
@onready var death_timer = $DeathTimer
@onready var marker = $Marker2D
@onready var animation_player = $AnimationPlayer
@onready var landing_dust_1 = $LandingDustLeap/CPUParticles2D2
@onready var stomp_dust_1 = $StompDustLeap/CPUParticles2D2
@onready var landing_dust_2 = $LandingDustLeap/CPUParticles2D
@onready var stomp_dust_2 = $StompDustLeap/CPUParticles2D
# Hurt particles
@onready var blood = $Blood/CPUParticles2D
@onready var death = $Death/CPUParticles2D
# Rock scene path to crush and spawn from air
var rock = preload("res://scenes/entities/rock.tscn")
# Boss config var
var player: Node2D = null
var current_attack = null
var has_attack = false
var is_attacking = false
var facing_right = true
var jump_velocity = -500
var leap_force = 600
var is_in_air = false
# To check if the player is too close (-1), a t medium range (0), or far (1)
var target_range: int = 1
# To add more difficulty later in the fight
var phase = 0
var attack_count = 0
var boss_flag = 1


var ui

var stats = {
	"name": "CABRAKAN",
	"max_hp": 1000,
	"health": 1000,
	"danger_health": 500,
	"contact_damage": 10,
	"attack_power": 30
}
# Dead or alive
var state = 0

func _ready():
	# Deactivate al hitboxes at the start
	if GameMaster.boss_slain[boss_flag]:
		call_deferred("queue_free")
	deactivate_all_hitboxes()
	# Init idle animation
	animated_sprite.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		update_air_animation()
	else:
		if is_in_air:
			landed()
		is_in_air = false
	
	if not is_attacking and is_on_floor():
		animated_sprite.play("Idle")
	
	# Turn to player while in Idle animation
	if not is_attacking and animated_sprite.animation == "Idle" and player != null:
		face_player()
	
	move_and_slide()

func hurt(damage):
	stats.health -= damage
	animation_player.play("hurt")
	ui.update_boss_health_bar(stats.max_hp, stats.health)
	blood.set_emitting(true)
	if stats.health < stats.danger_health and phase < 1:
		phase += 1
		activate_phase_2()
	if stats.health <= 0 and state == 0:
		die()

func activate_phase_2():
	rock_spawn_timer.start()

func die():
	spawn("hearth") # Spawn a hearth when defeated
	death.set_emitting(true)
	state = 1
	deactivate_entity()
	animated_sprite.play("Die")
	ui.setup_boss("", 1)
	death_timer.start()

func deactivate_entity():
	stomp_hit_box.set_process(false)
	stomp_hit_box.set_physics_process(false)
	stomp_hit_box.monitoring = false
	stomp_hit_box.set_deferred("monitorable",false)
	
	leap_hit_box.set_process(false)
	leap_hit_box.set_physics_process(false)
	leap_hit_box.monitoring = false
	leap_hit_box.set_deferred("monitorable",false)
	
	crush_hit_box.set_process(false)
	crush_hit_box.set_physics_process(false)
	crush_hit_box.monitoring = false
	crush_hit_box.set_deferred("monitorable",false)
	
	range.set_process(false)
	range.set_physics_process(false)
	range.monitoring = false
	range.set_deferred("monitorable",false)
	
	hurt_box.set_process(false)
	hurt_box.set_physics_process(false)
	hurt_box.monitoring = false
	hurt_box.set_deferred("monitorable",false)
	
	active_hit_box.set_process(false)
	active_hit_box.set_physics_process(false)
	active_hit_box.monitoring = false
	active_hit_box.set_deferred("monitorable",false)
	
	attack_timer.stop()
	
	# Halt any movemnt and frame check
	set_physics_process(false)

func face_player():
	if player:
		var should_face_right = player.global_position.x > global_position.x
		if should_face_right != facing_right:
			flip()

func flip():
	facing_right = !facing_right
	scale.x *= -1  # This flips every child node (way better than what we did on base_enemy.gd)

func update_air_animation():
	if velocity.y < 0:
		animated_sprite.play("Up")
	elif velocity.y > 0:
		animated_sprite.play("Down")

func landed():
	# Landing logic
	await get_tree().create_timer(1.1).timeout 
	if current_attack == "Leap":
		leap_landed()
	animated_sprite.play("Idle")
	is_attacking = false
	current_attack = null
	

func leap_landed():
	# Activate Landing hit boxes
	deactivate_all_hitboxes()
	leap_hit_box.set_deferred("monitoring", true)
	leap_hit_box.visible = true
	velocity *= 0
	landing_dust_1.set_emitting(true)
	landing_dust_2.set_emitting(true)
	await get_tree().create_timer(0.3).timeout
	leap_hit_box.set_deferred("monitoring", false)
	leap_hit_box.visible = false
	landing_dust_1.set_emitting(false)
	landing_dust_2.set_emitting(false)
	

func deactivate_all_hitboxes():
	stomp_hit_box.monitoring = false
	stomp_hit_box.visible = false
	leap_hit_box.monitoring = false
	leap_hit_box.visible = false
	crush_hit_box.monitoring = false
	crush_hit_box.visible = false
	stomp_dust_1.set_emitting(false)
	landing_dust_1.set_emitting(false)
	stomp_dust_2.set_emitting(false)
	landing_dust_2.set_emitting(false)

func attack():
	attack_count = 0
	print(target_range)
	if target_range != 0:
		leap_attack()
	else:
		var random_chance = randi_range(0, 8)
		if random_chance == 0:
			leap_attack()
		elif random_chance < 4:
			crush_attack()
		else:
			stomp_attack()

func leap_attack():
	if is_attacking: return
	is_attacking = true
	current_attack = "Leap"
	animated_sprite.play("Leap")
	await animated_sprite.animation_finished
	
	# Jump to player
	is_in_air = true
	var direction = sign(player.global_position.x - global_position.x)
	velocity = Vector2(direction * leap_force, jump_velocity)
	start_timer()

func stomp_attack():
	if is_attacking: return
	is_attacking = true
	current_attack = "Stomp"
	animated_sprite.play("Stomp")
	await animated_sprite.animation_finished
	
	# Activate stomp hitbox
	deactivate_all_hitboxes()
	stomp_hit_box.set_deferred("monitoring", true)
	stomp_hit_box.visible = true
	stomp_dust_1.set_emitting(true)
	stomp_dust_2.set_emitting(true)
	await get_tree().create_timer(0.3).timeout
	stomp_hit_box.set_deferred("monitoring", false)
	stomp_hit_box.visible = false
	stomp_dust_1.set_emitting(false)
	stomp_dust_2.set_emitting(false)
	# Recurssion yay!
	if phase == 1 and attack_count < 3:
		attack_count += 1
		is_attacking = false
		await stomp_attack()
	
	is_attacking = false
	current_attack = null
	animated_sprite.play("Idle")
	start_timer()

func crush_attack():
	if is_attacking: return
	is_attacking = true
	current_attack = "Crush"
	spawn_rock(0)
	animated_sprite.play("Crush")
	await animated_sprite.animation_finished
	
	is_attacking = false
	current_attack = null
	animated_sprite.play("Idle")
	start_timer()

func spawn_rock(type:int):
	# Direct bullet (original)
	var rock_instance = rock.instantiate()
	var spawn_pos
	if rock_instance.has_method("setup"):
		rock_instance.setup(type)
		if type == 0:
			spawn_pos = marker.global_position
		else:
			var random_vector: Vector2 = Vector2(randi_range(80,920), -750)
			spawn_pos = random_vector
	rock_instance.global_position = spawn_pos
	get_parent().add_child(rock_instance)

func spawn(item:String):
	Drops.place_drops(item, marker.global_position)

func start_timer():
	if attack_timer.time_left > 0:
		return false
		
	var time = randf_range(2, 4)
	attack_timer.start(time)

func _on_range_body_entered(body):
	if body.is_in_group("Player"):
		target_range = 0


func _on_range_body_exited(body):
	if body.is_in_group("Player"):
		target_range = 1
		
func _on_range_2_body_entered(body):
	if body.is_in_group("Player"):
		target_range = -1


func _on_range_2_body_exited(body):
	if body.is_in_group("Player"):
		target_range = 0

func _on_action_timer_timeout():
	attack()
	
func _on_death_timer_timeout():
	death.set_emitting(false)
	GameMaster.boss_slain[boss_flag] = true
	call_deferred("queue_free")

func _on_stomp_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(stats.attack_power)


func _on_active_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(stats.contact_damage)


func _on_leap_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(stats.attack_power)


func _on_crush_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(stats.attack_power)

func _on_rock_spawn_timer_timeout() -> void:
	spawn_rock(1)

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("HurtBox"):
		print("HURT")
		hurt(GameMaster.player_data.damage)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hurt(stats.contact_damage)
# We do it on this timer due to the freeing of the player on the scene manager script
func _on_get_player_timer_timeout() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	ui = get_tree().get_first_node_in_group("UI")
	ui.setup_boss(stats.name)
	ui.update_boss_health_bar(stats.max_hp, stats.health)
