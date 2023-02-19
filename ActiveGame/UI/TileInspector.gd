extends Sprite


onready var tilemapBase = get_node("/root/ActiveGame/World/Tilemaps/TileMap")
onready var tilemapBonus = get_node("/root/ActiveGame/World/Tilemaps/Bonus")

onready var MAP_SIZE = tilemapBase.get_used_rect().size * 64

onready var inspectorUI = get_node("/root/ActiveGame/UI/Inspector")

var coord = Vector2(0, 0)


func _ready():
	pass

func _process(delta):
	var mPos = get_global_mouse_position()
	
	coord = (mPos / 64)
	position.x = int(coord.x) * 64
	position.y = int(coord.y) * 64
	
	#print(position)
	
	if mPos.x <= 0 or mPos.y <= 0 or mPos.x >= MAP_SIZE.x or mPos.y >= MAP_SIZE.y:
		hide()
		inspectorUI.HideTerrain()
	else:
		show()
		inspectorUI.ShowTerrain(tilemapBase.get_cellv(coord), tilemapBonus.get_cellv(coord))
