extends Node2D

@export var size_x: int
@export var size_y: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_size_x():
	return size_x

func get_size_y():
	return size_y
