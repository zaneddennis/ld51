extends Node2D


func _ready():
	pass

func _process(delta):
	modulate.a = $Timer.time_left / $Timer.wait_time


func _on_Timer_timeout():
	queue_free()
