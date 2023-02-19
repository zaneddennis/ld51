extends Node2D


onready var ag = get_node("/root/ActiveGame")

var unitDir = 0


func _ready():
	pass

func _process(delta):
	position = get_global_mouse_position() / 64.0
	position = Vector2(int(position.x), int(position.y)) * 64 + Vector2(32, 32)


func Activate(unitName):
	var unitTileId = ag.get_node("World/Tilemaps/Units").tile_set.find_tile_by_name(unitName)
	var unitTextureRegion = ag.get_node("World/Tilemaps/Units").tile_set.tile_get_region(unitTileId)

	$Sprite.region_rect = unitTextureRegion
	
	var unitType = Database.cards[unitName]["unitType"]
	
	match unitType:
		"projectile":
			var maxRange = Database.cards[unitName]["maxRange"]
			for i in range(1, 1+maxRange):
				$TileMap.set_cell(0, -1 * i, 0)
		
		"melee":
			var aoeMap = Database.cards[unitName]["aoeMap"]
			for v in aoeMap:
				$TileMap.set_cellv(v, 0)
		
		"mage":
			var color = 0
			if unitName == "Woodland Sage":
				color = 1
			
			#var aoeMap = Database.cards[unitName]["aoeMap"]
			var spell = Database.cards[unitName]["spell"]
			var aoeMap = Spells.maps[spell]
			for v in aoeMap:
				$TileMap.set_cellv(v, color)
		
		_:
			pass


# takes either 1 or -1
func Rotate(dir=1):
	var used_cells = $TileMap.get_used_cells()
	if used_cells:
		var color = $TileMap.get_cellv(used_cells[0])
	
		$TileMap.clear()
	
		for v in used_cells:
			$TileMap.set_cellv(v.rotated(dir * (PI/2)), color)
	
		unitDir = (unitDir + dir) % 4
		if unitDir < 0:
			unitDir = 4 + unitDir
