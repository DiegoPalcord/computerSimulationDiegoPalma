extends CanvasLayer

@onready var coin_label = $Label
@onready var feather_count = $Label2
@onready var health_label = $Label3
@onready var health_bar = $HealthBar
@onready var msg = $msg
@onready var boss_name = $BossName
@onready var boss_health_bar = $HealthBarBoss

# Called when the node enters the scene tree for the first time.
func _ready():
	update_labels()
	update_health_bar()

func update_labels():
	coin_label.text = "🌰: " + str(GameMaster.player_data.coin)
	feather_count.text = "🍂: " + str(GameMaster.player_data.feathers)

func update_health_bar():
	health_label.text = str(GameMaster.player_data.hp) + " / " + str(GameMaster.player_data.max_hp)
	health_bar.update_value(GameMaster.player_data.max_hp,GameMaster.player_data.hp)
	
func update_boss_health_bar(max, current):
	boss_health_bar.update_value(max, current)

func update_msg(text:String):
	msg.text = text
# type is 0 to show and 1 t ohide the label and healthbar of the boss
func setup_boss(text:String, type:int =0):
	boss_name.text = text
	if type == 0:
		boss_name.visible = true
		boss_health_bar.visible = true
	if type == 1:
		boss_name.visible = false
		boss_health_bar.visible = false
