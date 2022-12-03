extends KinematicBody2D


onready var ag = get_node("/root/ActiveGame")


var direction = Vector2(0, 0)
var speed = 96
var maxRange = 0  # tiles
var damage = 0

var startPos = Vector2(0, 0)


func _ready():
	pass

func _process(delta):
	if ag.phase == "ACTION":
		var velocity = direction * speed
		var coll = move_and_collide(velocity * delta)
		
		if coll:
			coll.collider.get_parent().Attacked(damage, false)
			queue_free()
		
		if position.distance_to(startPos) >= (maxRange-1) * 64:
			queue_free()


func Activate(pos, dir, mr, a):
	startPos = pos
	
	direction = Vector2(0, -1).rotated(dir * (PI/2))
	startPos += direction * 64
	
	$Sprite.rotation = dir * (PI/2)
	
	position = startPos
	
	maxRange = mr
	damage = a
