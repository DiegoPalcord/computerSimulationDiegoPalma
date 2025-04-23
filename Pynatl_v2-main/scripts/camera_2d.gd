extends Camera2D

const LEFT_LIMIT = -100
const RIGHT_LIMIT = 1052
const TOP_LIMIT = -515
const BOTTOM_LIMIT = 133
const ROOM_SIZE_X = 1152
const ROOM_SIZE_Y = 648

@onready var timer = $Timer

var room: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up initial limits
	limit_left = LEFT_LIMIT
	limit_top = TOP_LIMIT
	limit_right = RIGHT_LIMIT
	limit_bottom = BOTTOM_LIMIT
	# wait for everything to load properly in scene
	timer.start()

# Puts the limits correctly dor the scene
func setup_camera_limits():
	var room_horizontal_size = SceneManager.get_size_on_x()
	var room_vertical_size = SceneManager.get_size_on_y()
	
	limit_left = LEFT_LIMIT
	limit_top = TOP_LIMIT
	limit_right = LEFT_LIMIT + (ROOM_SIZE_X * room_horizontal_size)
	limit_bottom = TOP_LIMIT + (ROOM_SIZE_Y * room_vertical_size)

func _on_timer_timeout():
	setup_camera_limits()
	print("--- Camera limits ---")
	print("top: ",limit_top)
	print("bottom: ",limit_bottom )
	print("left: ",limit_left)
	print("right: ",limit_right)
