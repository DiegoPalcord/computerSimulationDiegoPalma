extends CharacterBody2D

const SPEED = 18000.0
const JUMP_VELOCITY = -840.0
const GRAVITY_FACTOR = 2.2
const CROUCH_SPEED_REDUCTION = 0.5

# References
@onready var animated_sprite = $AnimatedSprite2D
@onready var special_spawn = $AnimatedSprite2D/Marker2D
@onready var attack_area = $Attack
@onready var attack_air_area = $AttackAir
@onready var attack_crouch_area = $AttackCrouch
@onready var animation_player = $AnimationPlayer
@onready var invincible_timer =  $InvincivilityFramesTimer
@onready var ui = get_tree().get_first_node_in_group("UI")

# State variables
var is_attacking = false
var is_ground_attack = false
var current_attack_animation = ""
var facing_right = true
var is_crouching = false
var can_stand_up = true
var was_going_up = false
var was_falling = false
var was_crouching = false
# Coyote time refers to the threshold when the player is airborn
# after falling from the ground but he can still jump
var coyote_time_threshold = 0.2
var coyote_time_counter = 0.0
var was_on_floor = false
var was_hit = false
var jump_count: int = 0

var proyectile = preload("res://scenes/entities/feather_proyectile.tscn")

func _ready():
	
	# Deactivate all attack areas
	deactivate_all_attack_areas()

func deactivate_all_attack_areas():
	attack_area.monitoring = false
	attack_area.monitorable = false
	attack_air_area.monitoring = false
	attack_air_area.monitorable = false
	attack_crouch_area.monitoring = false
	attack_crouch_area.monitorable = false
	attack_area.visible = false
	attack_air_area.visible = false
	attack_crouch_area.visible = false
	
func _physics_process(delta):
	set_collision_mask_value(8, true)
	# Check if we can stand up (not speakin of the experienced comedy format)
	check_can_stand_up()
	
	# Save logic
	if GameMaster.can_save == true and Input.is_action_just_pressed("interact"):
		ui.update_msg("Game Saved")
		GameMaster.save_game(get_tree().current_scene.scene_file_path, global_position)
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_FACTOR * delta
		if was_on_floor: # Check if we started falling from a platform
			coyote_time_counter = 0.0
		coyote_time_counter += delta
	else:
		if is_attacking and not is_ground_attack:
			is_attacking = false
			current_attack_animation = ""
		was_going_up = false
		was_falling = false
		coyote_time_counter = 0.0 #restart the coyote time
		jump_count = 0 #restart jump count

	# Jump
	if not SceneManager.transition_state and Input.is_action_just_pressed("jump") and (
	is_on_floor()
	or 
	coyote_time_counter < coyote_time_threshold # Allows a few forgiving frames to jump after falling
	or 
	jump_count < GameMaster.power_ups.moon_jump # Allows for multiple jumps on air
	) and not is_ground_attack and not is_crouching:
		velocity.y = JUMP_VELOCITY
		was_going_up = true
		if coyote_time_counter >= coyote_time_threshold:
			jump_count += 1
		else:
			coyote_time_counter = coyote_time_threshold 
		coyote_time_counter = coyote_time_threshold 
	# Save previous frame state
	was_on_floor = is_on_floor()
	
	#Special
	if not SceneManager.transition_state and Input.is_action_just_pressed("special"):
		if GameMaster.player_data.feathers > 1:
			GameMaster.change_feathers(2,1)
			special()
	
	# Crouch handling
	var just_crouched = false
	if not SceneManager.transition_state and  Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_attacking and not is_crouching:
		is_crouching = true
		was_crouching = true
		just_crouched = true
	elif not SceneManager.transition_state and  Input.is_action_pressed("ui_down") and is_on_floor() and not is_attacking:
		is_crouching = true
	elif not SceneManager.transition_state and not Input.is_action_pressed("ui_down") and can_stand_up:
		is_crouching = false
		was_crouching = false
	
	if not SceneManager.transition_state and is_crouching and Input.is_action_just_pressed("jump"):
		set_collision_mask_value(8, false)
		global_position.y += 2

	# Horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if not SceneManager.transition_state and direction and not is_ground_attack and not (is_crouching and is_on_floor()):
		var current_speed = SPEED * (CROUCH_SPEED_REDUCTION if is_crouching else 1.0)
		velocity.x = direction * current_speed * delta
		if direction > 0:
			animated_sprite.scale.x = abs(animated_sprite.scale.x)
			facing_right = true
		elif direction < 0:
			animated_sprite.scale.x = -abs(animated_sprite.scale.x)
			facing_right = false
	elif not is_ground_attack:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_ground_attack:
		velocity.x = 0

	move_and_slide()
	
	update_animations(direction, just_crouched)

func check_can_stand_up():
	can_stand_up = true
	# For future development

func update_animations(direction, just_crouched):
	if is_attacking:
		if is_on_floor() and not is_ground_attack:
			is_attacking = false
			current_attack_animation = ""
		else:
			return
	
	# Priority 1: attacks
	if Input.is_action_just_pressed("attack"):
		if is_crouching and is_on_floor():
			play_attack("Crouch attack", true)
		elif is_on_floor():
			play_attack("Attack", true)
		else:
			play_attack("Attack air", false)
		return
	
	# Priority 2: Airbone animations
	if not is_on_floor():
		if velocity.y < 0:
			if not was_going_up or animated_sprite.animation != "Up":
				animated_sprite.play("Going up")
				deactivate_all_attack_areas()
				await animated_sprite.animation_finished
				if not is_on_floor() and velocity.y < 0:
					animated_sprite.play("Up")
					was_going_up = true
					was_falling = false
		else:
			if not was_falling or animated_sprite.animation != "Falling":
				animated_sprite.play("Fall")
				deactivate_all_attack_areas()
				await animated_sprite.animation_finished
				if not is_on_floor() and velocity.y >= 0:
					animated_sprite.play("Falling")
					was_falling = true
					was_going_up = false
		return
	
	# Priority 3: crouching
	if is_crouching:
		# Only play "Crouch if we are crouching and are not attacking
		if (just_crouched or not was_crouching) and animated_sprite.animation != "Crouch attack":
			animated_sprite.play("Crouch")
			deactivate_all_attack_areas()
			await animated_sprite.animation_finished
			if is_crouching and not is_attacking:
				animated_sprite.play("Crouching")
		elif animated_sprite.animation != "Crouch attack":
			animated_sprite.play("Crouching")
		return
	
	# Priority 4: Regular on floor animations
	if direction != 0:
		animated_sprite.play("Run")
		deactivate_all_attack_areas()
	else:
		animated_sprite.play("Idle")
		deactivate_all_attack_areas()

func play_attack(anim_name, is_ground_attack_locale):
	is_attacking = true
	current_attack_animation = anim_name
	self.is_ground_attack = is_ground_attack_locale
	deactivate_all_attack_areas()
	update_attack_areas_direction()
	
	# Activate corresponfing Area2D
	match anim_name:
		"Attack":
			attack_area.monitoring = true
			attack_area.monitorable = true
			attack_area.visible = true
		"Attack air":
			attack_air_area.monitoring = true
			attack_air_area.monitorable = true
			attack_air_area.visible = true
		"Crouch attack":
			attack_crouch_area.monitoring = true
			attack_crouch_area.monitorable = true
			attack_crouch_area.visible = true
	
	var prev_air_state = null
	if not is_ground_attack:
		if was_going_up:
			prev_air_state = "Up"
		elif was_falling:
			prev_air_state = "Falling"
	
	animated_sprite.play(anim_name)
	
	if is_ground_attack:
		velocity.x = 0
	
	await animated_sprite.animation_finished
	is_attacking = false
	current_attack_animation = ""
	self.is_ground_attack = false
		
	if not is_on_floor() and not is_ground_attack:
		if prev_air_state == "Up":
			animated_sprite.play("Up")
		elif prev_air_state == "Falling":
			animated_sprite.play("Falling")
	elif is_crouching and anim_name != "Crouch attack":
		animated_sprite.play("Crouching")

func update_attack_areas_direction():
	# Adjust direction of the Area2D nodes
	if facing_right:
		attack_area.scale.x = abs(attack_area.scale.x)
		attack_air_area.scale.x = abs(attack_air_area.scale.x)
		attack_crouch_area.scale.x = abs(attack_crouch_area.scale.x)
	else:
		attack_area.scale.x = -abs(attack_area.scale.x)
		attack_air_area.scale.x = -abs(attack_air_area.scale.x)
		attack_crouch_area.scale.x = -abs(attack_crouch_area.scale.x)

func special():
	# Direct bullet (original)
	var bullet = proyectile.instantiate()
	var spawn_pos = special_spawn.global_position
	bullet.global_position = spawn_pos
	bullet.direction = Vector2(1 if facing_right else -1, 0)
	get_parent().add_child(bullet)
	
	# Angled proyectile
	var angle_bullet = proyectile.instantiate()
	angle_bullet.global_position = spawn_pos
	var angle = deg_to_rad(23)
	angle_bullet.direction = Vector2(
		cos(angle) * (1 if facing_right else -1),
	-sin(angle)  # Negative Y because in Godot Y axis is negative
	)
	get_parent().add_child(angle_bullet)


func hurt(damage):
	if was_hit == false:
		was_hit = true
		invincible_timer.start()
		animation_player.play("hit_flash")
		GameMaster.change_health(damage, 1)
		ui.update_health_bar()

func do_damage(body):
	if body.is_in_group("Enemy") or body.is_in_group("HurtBox"):
		if body.has_method("hurt"):
			body.hurt(GameMaster.player_data.damage)

func _on_attack_body_entered(body):
	do_damage(body)

func _on_attack_air_body_entered(body):
	do_damage(body)

func _on_attack_crouch_body_entered(body):
	do_damage(body)

func _on_invincivility_frames_timer_timeout():
	was_hit = false
