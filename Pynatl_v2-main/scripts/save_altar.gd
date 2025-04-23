extends Node2D

var text = "Press E to save on PC or Press the Green button (on top the Movement Arrow Buttons) in mobile"
var text_2 = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	GameMaster.can_save = true
	var ui = get_tree().get_first_node_in_group("UI")
	ui.update_msg(text)

func _on_area_2d_body_exited(body: Node2D) -> void:
	GameMaster.can_save = false
	var ui = get_tree().get_first_node_in_group("UI")
	ui.update_msg(text_2)
