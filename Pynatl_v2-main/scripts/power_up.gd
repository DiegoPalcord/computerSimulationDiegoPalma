extends Node2D

@export var hability: String
@export var hability_flag: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Removes it from scene if the power up falg is true, meaning was collected before
	if GameMaster.power_up_flags[hability_flag] == true:
		call_deferred("queue_free")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameMaster.power_ups[hability] += 1
		GameMaster.power_up_flags[hability_flag] = true
		call_deferred("queue_free")
