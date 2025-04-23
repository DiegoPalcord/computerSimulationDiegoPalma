extends CharacterBody2D

const LOCK_POSITION = 260
@export var flag: int
@export var animation_duration: float = 0.4
@export var unlocked = true
@export var assigned_boss = 0


func _ready() -> void:
	if GameMaster.boss_slain[assigned_boss]:
		call_deferred("queue_free")

func _process(delta: float) -> void: 
	if GameMaster.boss_slain[assigned_boss]:
		unlock()

func lock():
	unlocked = false
	var tween = create_tween()
	tween.tween_property(self, "global_position", 
						 global_position + Vector2(0, LOCK_POSITION), 
						 animation_duration)
	# Easing makes it look more natural
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func unlock():
	unlocked = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", 
						 global_position - Vector2(0, LOCK_POSITION), 
						 animation_duration)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and unlocked and not GameMaster.door_flags[flag] and not GameMaster.boss_slain[assigned_boss]:
		lock()
