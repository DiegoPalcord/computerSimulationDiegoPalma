extends Area2D

@export var text: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	var ui = get_tree().get_first_node_in_group("UI")
	if ui != null:
		ui.update_msg(text)
	
func _on_body_exited(body):
	var ui = get_tree().get_first_node_in_group("UI")
	if ui != null:
		ui.update_msg("")
