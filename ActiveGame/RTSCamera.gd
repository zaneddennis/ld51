extends Camera2D


const SCREEN_SIZE = Vector2(1600, 900)
const MARGIN = 64
const SCROLL_SPEED = 256

onready var ag = get_parent()


func _ready():
	pass

func _process(delta):
	
	if ag.phase != "GAME_OVER":
		var mPos = get_viewport().get_mouse_position()
	
		var velocity = Vector2(0, 0)
	
		if mPos.x <= MARGIN:
			velocity.x = -1 * SCROLL_SPEED
		elif mPos.x >= SCREEN_SIZE.x - MARGIN:
			velocity.x = SCROLL_SPEED
			
		if mPos.y <= MARGIN:
			velocity.y = -1 * SCROLL_SPEED
		elif mPos.y >= SCREEN_SIZE.y - MARGIN:
			velocity.y = SCROLL_SPEED
	
		translate(velocity * delta)
