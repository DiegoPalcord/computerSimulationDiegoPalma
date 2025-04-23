extends Node

@onready var transition_cover = $TransitionCover
@onready var loading_screen_timer = $LoadingScreenTimer
@onready var entry_scene_label = $TransitionCover/EntryTextLabel
@onready var exit_scene_label = $TransitionCover/ExitTextLabel
@onready var cutscene_timer = $CutsceneTimer
@onready var finish_timer = $FinishGameTimer

var current_level_scene: Node2D
var current_level_x_size: int = 1
var current_level_y_size: int = 1

var transition_state: bool
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")

func _ready() -> void:
	if GameMaster.opening_cutscene_viewed == false:
		entry_scene_label.visible = true
		transition_state = true
		transition_cover.visible = true
		cutscene_timer.start()

func change_level(new_level_path: String, target_door_id: int):
	# Hides everything and makes the player unable to move
	loading_screen_timer.start()
	transition_state = true
	transition_cover.visible = true
		
	# We delete any existing player nodes:
	remove_existing_player()
	
	var new_level = load(new_level_path).instantiate()
	# Add scene to tree
	get_tree().root.add_child(new_level)
	# Hold for a frame to give time to properly load
	await get_tree().process_frame
	
	GameMaster.remove_all_players()
	
	# Look for the destined door in the new scene
	var spawn_position = Vector2(300,-75) # Default pos
	var target_door = find_target_door(new_level, target_door_id)
	if target_door:
		spawn_position = target_door.global_position

	
	var player = PLAYER_SCENE.instantiate() # Instantiate player
	player.set_process_unhandled_input(false)
	new_level.add_child(player) # Add player to scene
	print("Player pos: ", spawn_position)
	player.global_position = spawn_position # Move player to the position of the door
	
	# Delete previous scene if it still exists
	if get_tree().current_scene != null:
		var old_scene =  get_tree().current_scene
		get_tree().root.remove_child(old_scene)
		old_scene.queue_free()
	
	# We stablish the new scene as current scene
	get_tree().current_scene = new_level
	
	var current_level = get_tree().current_scene
	if current_level != new_level:
		get_tree().root.remove_child(current_level)
		
	update_room_size(new_level)

func update_room_size(new_level):
		# Update room size
	get_tree().current_scene = new_level
	if new_level.has_method("get_size_x"):
		current_level_x_size = new_level.get_size_x()
	if new_level.has_method("get_size_y"):
		current_level_y_size = new_level.get_size_y()

func find_target_door(level, door_id):
	var destined_door
	print("--------------------------------------------------------")
	print("Destined Level: ", level)
	for child in level.get_children():
		if child.is_in_group("Doors") and child.door_id == door_id:
			print("Destined door: ", child)
			print("Destined door_id: ", child.door_id)
			print("Destined door destined door id: ", child.destined_door_id)
			return child
			break
	return null

func remove_existing_player():
	var existing_players = get_tree().get_nodes_in_group("Player")
	for existing_player in existing_players:
		if existing_player.get_parent():
			existing_player.get_parent().remove_child(existing_player)
		existing_player.queue_free()

func play_ending():
	transition_state = true
	entry_scene_label.visible = false
	exit_scene_label.visible = true
	transition_state = true
	transition_cover.visible = true
	cutscene_timer.start()
	finish_timer.start()

func get_size_on_x():
	return current_level_x_size

func get_size_on_y():
	return current_level_y_size


func _on_loading_screen_timer_timeout() -> void:
	transition_state = false
	transition_cover.visible = false


func _on_cutscene_timer_timeout() -> void:
	transition_state = false
	entry_scene_label.visible = false
	exit_scene_label.visible = false
	transition_cover.visible = false


func _on_finish_game_timer_timeout() -> void:
	GameMaster.die()
