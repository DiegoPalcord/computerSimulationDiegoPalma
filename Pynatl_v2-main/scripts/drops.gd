extends Node

var items: Dictionary = {
	"feathers": preload("res://scenes/entities/feather_pick_up.tscn"),
	"hearth": preload("res://scenes/entities/hearth.tscn")
}

# Makes instances of scenes (Pick Ups) and places them where needed
#receives the name of the item and the global position of who called it
func place_drops(item: String, position: Vector2):
	if item in items:
		var item_instance = items[item].instantiate()
		call_deferred("add_child", item_instance)
		item_instance.global_position = position
	# Error handling
	else:
		push_error("Item not found in dictionary: " + item)

func _deferred_instance_item(item_scene: PackedScene, position: Vector2):
	var item_instance = item_scene.instantiate()
	item_instance.global_position = position
	get_tree().current_scene.add_child(item_instance)
