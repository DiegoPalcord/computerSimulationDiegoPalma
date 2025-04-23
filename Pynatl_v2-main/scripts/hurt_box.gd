extends Area2D
# Timer to prevent drom multiple damage for each hurtbox
@onready var timer = $Timer
var was_hit = false

# Called when the node enters the scene tree for the first time.
func hurt(damage):
	var parent= get_parent()
	
	if was_hit == false:
		was_hit = true
		if parent.has_method("hurt"):
			parent.hurt(damage)


func _on_timer_timeout():
	was_hit=false


func _on_area_entered(area):
	if area.is_in_group("HurtBox"):
		hurt(GameMaster.player_data.damage)
