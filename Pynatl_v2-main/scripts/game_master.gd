#GameMaster
extends Node

var can_save = false
var player = preload("res://scenes/entities/player.tscn")
var opening_cutscene_viewed = false

var player_data: Dictionary = {
	"max_hp": 100, # Starts with 100
	"hp": 100,
	"damage": 10, # Starts with 10
	"coin": 0,
	"jaguar_pelt": 0,
	"feathers": 40,
	"obsidian": 0,
	"hearths": 0, 
}

var power_ups: Dictionary = {
	"moon_jump": 0, # Amount of jumps the player can do
}

var obsidian_flags: Dictionary = {
	0: false,
	1: false,
	2: false,
	3: false,
}
var hearth_flags: Dictionary = {
	0: false,
	1: false,
	2: false,
}
var power_up_flags: Dictionary = {
	0: true, # for default purposes
	1: false, # first moon jump upgrade 
}
var boss_slain: Dictionary = {
	0: false, # Default
	1: false, # Cabrakan (The Mayan God of Mountains and Earthquakes
}
var door_flags: Dictionary = {
	1: false
}

var current_scene: String = "res://scenes/areas/tropical_forest/tropical_forest_00.tscn"
var player_position: Vector2 = Vector2(240, -80)
# To handle mobile related things
var mobile_device = true

func is_mobile() -> bool:
	var os_name = OS.get_name()
	return os_name == "Android" or os_name == "iOS"

func _ready() -> void:
	if is_mobile():
		mobile_device = true
	else:
		mobile_device = false

func save_game(scene_path: String, position: Vector2):
	player_data.hp = player_data.max_hp
	current_scene = scene_path
	player_position = position
	var save_data = {
		"player_data": player_data,
		"power_ups": power_ups,
		"obsidian_flags": obsidian_flags,
		"hearth_flags": hearth_flags,
		"door_flags": door_flags,
		"current_scene": current_scene,
		"player_position": {"x": player_position.x, "y": player_position.y}
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_var(save_data)
	save_file.close()
	print("Juego guardado correctamente")

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("No hay archivo de guardado")
		player_data = {
			"max_hp": 100, # Starts with 100
			"hp": 100,
			"damage": 10, # Starts with 10
			"coin": 0,
			"jaguar_pelt": 0,
			"feathers": 40,
			"obsidian": 0,
			"hearths": 0, 
		}
		power_ups = {
			"moon_jump": 0, # Amount of jumps the player can do
		}
		obsidian_flags = {
			0: false,
			1: false,
			2: false,
			3: false,
		}
		hearth_flags = {
			0: false,
			1: false,
			2: false,
		}
		power_up_flags = {
			0: true, # for default purposes
			1: false, # first moon jump upgrade 
		}
		boss_slain= {
			0: false, # Default
			1: false, # Cabrakan (The Mayan God of Mountains and Earthquakes
		}
		door_flags = {
			1: false
		}
		current_scene = "res://scenes/areas/tropical_forest/tropical_forest_00.tscn"
		player_position = Vector2(250,-80)
		return true
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var save_data = save_file.get_var()
	save_file.close()
	
	player_data = save_data["player_data"]
	power_ups = save_data["power_ups"]
	obsidian_flags = save_data["obsidian_flags"]
	hearth_flags = save_data["hearth_flags"]
	door_flags = save_data["door_flags"]
	current_scene = save_data["current_scene"]
	player_position = Vector2(save_data["player_position"]["x"], save_data["player_position"]["y"])
	
	print("Juego cargado correctamente")
	return true

func change_health(amount, type):
	match type: 
		0: # Heal
			player_data.hp += amount
			if player_data.hp > player_data.max_hp:
				player_data.hp = player_data.max_hp
		1: # Hurt
			player_data.hp -= amount
		2: # Set
			player_data.hp = amount
	var ui = get_tree().get_first_node_in_group("UI")
	ui.update_health_bar()
		
	if player_data.hp <= 0:
		die()

func change_max_hp(amount, type, flag = 00):
	match type: 
		0: # Heal
			player_data.max_hp += amount
			player_data.hp = player_data.max_hp
			player_data.hearths += 1
			hearth_flags[flag] = true
		1: # Hurt
			player_data.max_hp -= amount
			player_data.hp = player_data.max_hp
		2: # Set
			player_data.hp = amount
			player_data.hp = player_data.max_hp
	var ui = get_tree().get_first_node_in_group("UI")
	ui.update_health_bar()

func change_damage(amount, type, flag = 00):
	match type: 
		0: # Heal
			player_data.damage += amount
			player_data.obsidian += 1 
			obsidian_flags[flag] = true
		1: # Hurt
			player_data.damage -= amount
		2: # Set
			player_data.damage = amount

func change_cocoa(amount, type):
	match type: 
		0: # Aquire
			player_data.coin += amount
			if player_data.coin > 9999:
				player_data.coin = 9999
		1: # Spend
			player_data.coin -= amount
		2: # Set ('cause why nout)
			player_data.coin = amount
	var ui = get_tree().get_first_node_in_group("UI")
	ui.update_labels()

func change_feathers(amount, type):
	match type: 
		0: # Aquire
			player_data.feathers += amount
			if player_data.feathers > 45:
				player_data.feathers = 45
		1: # Spend
			player_data.feathers -= amount
		2: # Set ('cause why nout)
			player_data.feathers = amount
	var ui = get_tree().get_first_node_in_group("UI")
	ui.update_labels()

func unlock_door(flag):
	door_flags[flag]

func start_game():
	if get_node("/root/GameMaster").load_game():
		get_tree().change_scene_to_file(GameMaster.current_scene)
		await get_tree().tree_changed
		await get_tree().create_timer(1)
		remove_all_players()
		await get_tree().create_timer(1)
		var player_instance = player.instantiate()
		await get_tree().process_frame # Wait a frame to load scene (this awaits always work janky I recommend use timers better)
		get_tree().current_scene.add_child(player_instance)
		SceneManager.update_room_size(get_tree().current_scene)
		if player_instance:
			player_instance.global_position = player_position

func remove_all_players():
	var players = get_tree().current_scene.get_tree().get_nodes_in_group("Player")
	for p in players:
		p.queue_free()

func die():
	start_game()
