extends Node


onready var ag = get_parent()


func _ready():
	pass


func PickCard(playerSelectionIx):
	var valid = []
	
	for i in range(1, 4+1):
		if i != playerSelectionIx:
			var costs = Database.cards[ag.activeCards[i]]["cost"]
			var validCard = true
			for r in costs:
				if costs[r] > ag.opponentResources[r]:
					validCard = false
			
			if validCard:
				valid.append(i)
	
	if len(valid) <= 0:
		return -1
	else:
		return Util.Choice(valid)


func PickTile(unitName):
	# get territory limit
	var yLim = 0
	for ui in ag.get_node("World/Units").get_children():
		if ui.unitTeam == 1 and ui.coords.y > yLim:
			yLim = ui.coords.y
	yLim += 1
	
	# initialize validity map
	var tmPlace = InitializeTMPlace(yLim)
	
	# pick tile
	if unitName == "Peasant":
		return PickTilePeasant(tmPlace, yLim)
	else:
		return PickTileElse(tmPlace, yLim)

func PickTilePeasant(tmPlace, yLim):
	var openResTiles = GetOpenResourceTiles(yLim)
	
	# get available resources
	var availResources = []
	for v in openResTiles:
		var tId = ag.get_node("World/Tilemaps/Bonus").get_cellv(v)
		var tName = ag.get_node("World/Tilemaps/Bonus").tile_set.tile_get_name(tId)
		var res = Database.bt2Resource[tName]
		availResources.append(res)
	
	if availResources:
		# get most needed
		var resourceNeeds = Util.DictSort(ag.opponentResources)
		
		var most = null
		var i = 0
		while not most in availResources:
			most = resourceNeeds[i][0]
			i += 1
		
		var btId = ag.get_node("World/Tilemaps/Bonus").tile_set.find_tile_by_name(Database.res2Bt[most])
		
		# pick a random tile of that resource
		var choices = []
		for v in openResTiles:
			if ag.get_node("World/Tilemaps/Bonus").get_cellv(v) == btId:
				choices.append(v)
		
		return Util.Choice(choices)
	
	#if choices:
	#	return Util.Choice(choices)
	else:
		PickTileElse(tmPlace, yLim)

# todo: make this only pick from front line spots
func PickTileElse(tmPlace, yLim):
	var coords = Vector2(randi()%16, yLim)
	while tmPlace.get_cellv(coords) != 0:  # if bad selection, try again
		coords = Vector2(randi()%16, yLim)
	return coords


func GetOpenResourceTiles(yLim):
	var tmBonus = ag.get_node("World/Tilemaps/Bonus")
	var tmUnits = ag.get_node("World/Tilemaps/Units")
	
	var result = []
	for v in tmBonus.get_used_cells():
		if v.y <= yLim and tmUnits.get_cellv(v) == -1 and tmBonus.get_cellv(v) < 4:
			result.append(v)
	
	return result

func InitializeTMPlace(yLim):
	var tmTerrain = ag.get_node("World/Tilemaps/TileMap")
	var tmUnits = ag.get_node("World/Tilemaps/Units")
	var tmPlace = ag.get_node("World/Tilemaps/UnitPlacement")
	for v in tmTerrain.get_used_cells():
		if v.y <= yLim and tmTerrain.get_cellv(v) in [1] and tmUnits.get_cellv(v) == -1:
			tmPlace.set_cellv(v, 0)
	
	return tmPlace
