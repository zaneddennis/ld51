extends Node


func _ready():
	pass


func Choice(arr):
	assert(len(arr) > 0)
	
	return arr[randi()%len(arr)]


func DictMin(d):
	assert(len(d) > 0)
	
	var kMin = null
	var vMin = INF
	for k in d:
		if d[k] < vMin:
			vMin = d[k]
			kMin = k
	return kMin

class KeySort:
	static func sort_ascending(a, b):
		if a[1] < b[1]:
			return true
		return false
	
	static func sort_descending(a, b):
		if a[1] > b[1]:
			return true
		return false

# returns an Array of keys of the dict, in order by their keys
func DictSort(d, asc=true):
	
	assert(len(d) > 0)
	
	# convert dict to Array
	var arr = []
	for k in d:
		arr.append([k, d[k]])
	
	if asc:
		arr.sort_custom(KeySort, "sort_ascending")
	else:
		arr.sort_custom(KeySort, "sort_descending")
	return arr


func TransformAOEMap(map, dir):
	var result = []
	for v in map:
		result.append(v.rotated(dir*(PI/2)))
	return result
