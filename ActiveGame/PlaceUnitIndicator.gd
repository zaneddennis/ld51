extends Node2D


onready var ag = get_node("/root/ActiveGame")


func _ready():
	pass

func _process(delta):
	position = get_global_mouse_position() / 64.0
	position = Vector2(int(position.x), int(position.y)) * 64 + Vector2(32, 32)


func Activate(unitName):
	var unitTileId = ag.get_node("World/Tilemaps/Units").tile_set.find_tile_by_name(unitName)
	var unitTextureRegion = ag.get_node("World/Tilemaps/Units").tile_set.tile_get_region(unitTileId)
	#var unitTexture = unitsTexture.duplicate()
	#print(unitTexture)
	
	#$Sprite.texture = unitTexture
	$Sprite.region_rect = unitTextureRegion
