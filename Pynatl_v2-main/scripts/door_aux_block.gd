# This whole script reason of being is because of a problem discussed in the problems log
# the one about going trough multiple doors while the stage loads correctly
# its whole purpose is to destroy the block on the door that we can activate when loading the scene

extends StaticBody2D


func _on_door_aux_block_timer_timeout() -> void:
	call_deferred("queue_free")
