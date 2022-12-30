extends Camera2D


onready var ag = get_parent()

onready var SCREEN_SIZE = get_viewport_rect().size
onready var MAP_SIZE = ag.get_node("World/Tilemaps/TileMap").get_used_rect().size * 64
const MARGIN = 32
const SCROLL_SPEED = 256


func _ready():
	position = MAP_SIZE / 2

func _process(delta):
	
	if ag.phase != "GAME_OVER":
		var velocity = Vector2(0, 0)
		velocity = ProcessKeyboardInput(velocity)
		if not velocity:
			velocity = ProcessMouseInput(velocity)
	
		translate(velocity * delta)
		
		position.x = clamp(position.x, 0, MAP_SIZE.x)
		position.y = clamp(position.y, 0, MAP_SIZE.y)

func ProcessKeyboardInput(velocity):
	if Input.is_action_pressed("ui_up"):
		velocity.y = -1 * SCROLL_SPEED
	if Input.is_action_pressed("ui_down"):
		velocity.y = SCROLL_SPEED
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1 * SCROLL_SPEED
	if Input.is_action_pressed("ui_right"):
		velocity.x = SCROLL_SPEED
	
	return velocity

func ProcessMouseInput(velocity):
	var mPos = get_viewport().get_mouse_position()
	
	if mPos.x <= MARGIN:
		velocity.x = -1 * SCROLL_SPEED
	elif mPos.x >= SCREEN_SIZE.x - MARGIN:
		velocity.x = SCROLL_SPEED
		
	if mPos.y <= MARGIN:
		velocity.y = -1 * SCROLL_SPEED
	elif mPos.y >= SCREEN_SIZE.y - MARGIN:
		velocity.y = SCROLL_SPEED
	
	return velocity
