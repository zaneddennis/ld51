extends KinematicBody2D


onready var ag = get_node("/root/ActiveGame")


export var direction = -1
var speed = 96
var maxRange = 0  # tiles
var damage = 0

var startPos = Vector2(0, 0)


func _ready():
	pass

func _process(delta):
	if ag.phase == "ACTION":
		var velocity = Vector2(0, direction) * speed
		var coll = move_and_collide(velocity * delta)
		
		if coll:
			coll.collider.get_parent().Attacked(damage, false)
			queue_free()
		
		if position.distance_to(startPos) >= (maxRange-1) * 64:
			queue_free()


func Activate(pos, dir, mr, a):
	startPos = pos
	
	direction = dir
	if direction == 1:  # down
		$Sprite.flip_v = true
		startPos.y += 64
	else:
		startPos.y -= 64
		
	position = startPos
	
	maxRange = mr
	damage = a
