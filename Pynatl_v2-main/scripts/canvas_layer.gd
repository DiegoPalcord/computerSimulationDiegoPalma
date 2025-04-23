extends CanvasLayer

@onready var fade = $Fade
var player_ref: Node

func _ready():
	fade.visible = false

func start_transition(player: Node):
	player_ref = player
	player_ref.set_process_input(false)  # Bloquear controles
	
	fade.visible = true
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.3)  # Fade a negro
	
	await tween.finished
	emit_signal("transition_started")

func end_transition():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.3)  # Fade a transparente
	await tween.finished
	
	fade.visible = false
	player_ref.set_process_input(true)  # Restaurar controles
