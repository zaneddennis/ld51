extends Node


func _ready():
	pass


func TransformAOEMap(map, dir):
	var result = []
	for v in map:
		result.append(v.rotated(dir*(PI/2)))
	return result
