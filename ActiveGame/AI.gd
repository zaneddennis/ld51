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
	var unitInfo = Database.cards[unitName]
	var unitType = unitInfo["unitType"]
	
	# get territory limit
	var yLim = 0
	for ui in ag.get_node("World/Units").get_children():
		if ui.unitTeam == 1 and ui.coords.y > yLim:
			yLim = ui.coords.y
	yLim += 1
	
	# initialize validity map
	var tmPlace = InitializeTMPlace(yLim)
	
	# pick tile
	if unitType == "Peasant":
		return PickTilePeasant(tmPlace, yLim)
	elif unitType == "melee":
		return PickTileMelee(tmPlace, yLim)
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
				choices.append([v, 2])
		
		return Util.Choice(choices)
	
	else:
		PickTileElse(tmPlace, yLim)

func PickTileMelee(tmPlace, yLim):
	# get open spots in first 3 lines
	var candidates = GetOpenTiles(tmPlace, yLim-3, yLim)
	
	# initialize score map
	var scores = {}
	for v in candidates:
		for i in range(4):
			scores[[v, i]] = 0
	
	# if facing enemy, add score
	var tmUnits = ag.get_node("World/Tilemaps/Units")
	for vDir in scores:
		var coord = vDir[0] + Vector2.UP.rotated((PI/2) * vDir[1])
		if tmUnits.get_cellv(coord) != -1:
			var unit = ag.CheckForUnit(coord)
			if unit.unitTeam == 0:  # facing player unit
				scores[vDir] += 1
			elif unit.unitTeam == 1:  # facing own teammate
				scores[vDir] -= 2
	
	# if on defensive terrain, add score
	var tmBonus = ag.get_node("World/Tilemaps/Bonus")
	for vDir in scores:
		var coord = vDir[0]
		if tmBonus.get_cellv(coord) == 1:
			scores[vDir] += 1
		elif tmBonus.get_cellv(coord) == 5:
			scores[vDir] += 2
	
	# of tiles with highest score, pick random
	var sorted = Util.DictSort(scores, false)
	var maxScore = sorted[0][1]
	
	var finalCandidates = []
	for vDirScore in sorted:
		var vDir = vDirScore[0]
		var score = vDirScore[1]
		
		if score == maxScore:
			finalCandidates.append(vDir)
		else:
			break
	
	return Util.Choice(finalCandidates)
	
func PickTileElse(tmPlace, yLim):
	var coords = Vector2(randi()%16, yLim)
	while tmPlace.get_cellv(coords) != 0:  # if bad selection, try again
		coords = Vector2(randi()%16, yLim)
	return [coords, 2]


func GetOpenTiles(tmPlace, yMin, yLim):
	var result = []
	for v in tmPlace.get_used_cells():
		if v.y >= yMin and v.y <= yLim:
			result.append(v)
	return result

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
