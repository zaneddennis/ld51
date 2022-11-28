extends Control

# THIS IS OLD, ONLY HERE FOR POSTERITY


onready var ag = get_parent().get_parent()
onready var tm = ag.get_node("World/Tilemaps/TileMap")


func _ready():
	pass


func _process(delta):
	if visible:
		var mPos = tm.get_local_mouse_position()
		var coords = tm.world_to_map(mPos)
		
		HoverTile(coords)
		
		if Input.is_action_just_pressed("left_click"):
			AttemptSelectTile(coords)
		
		for r in $ResourcesPanel/VBoxContainer.get_children():
			r.get_node("Label").text = str(ag.playerResources[r.name])


func HoverTile(coords):
	pass


func AttemptSelectTile(coords):
	var terrain = tm.get_cellv(coords)
	
	if not terrain in [-1, 0]:
		SelectTile(coords)

func SelectTile(coords):
	print("Placing on tile: ", coords)
	
	ag.EnterAction()
