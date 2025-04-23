extends ProgressBar

var max: int = 100
var current: int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_values(entity_max:int, entity_current:int):
	max = entity_max
	current = entity_current
	var tween = create_tween()
	tween.tween_property(self, "max_value", max, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "value", current, 0.5).set_trans(Tween.TRANS_LINEAR)

func update_value(entity_max:int, entity_current:int):
	max = entity_max
	current = entity_current
	var tween = create_tween()
	tween.tween_property(self, "max_value", max, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "value", current, 0.5).set_trans(Tween.TRANS_LINEAR)
