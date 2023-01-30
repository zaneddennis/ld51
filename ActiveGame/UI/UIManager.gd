extends CanvasLayer

var PlaceUnitIndicator = preload("res://ActiveGame/PlaceUnitIndicator.tscn")


onready var ag = get_parent()
onready var unitsTexture = AtlasTexture.new()

var playerSelection = ""
var playerSelectionIx = -1
var opponentSelection = ""
var opponentSelectionIx = -1


func _ready():
	unitsTexture.atlas = load("res://ActiveGame/Art/Tiles/Units.png")
	
	for i in range(1, 5):
		var co = $Common/CardsPanel/VBoxContainer.get_node("CardOption" + str(i))
		co.connect("mouse_entered", self, "_on_CardOption_mouse_entered", [i])
		#co.connect("mouse_exited", self, "_on_CardOption_mouse_exited", [i])
		
		co.get_node("Button").connect("mouse_entered", self, "_on_CardOptionButton_mouse_entered", [co])
		co.get_node("Button").connect("mouse_exited", self, "_on_CardOptionButton_mouse_exited", [co])
		co.get_node("Button").connect("pressed", self, "_on_CardOptionButton_pressed", [i])
	
	for r in ["Food", "Wood", "Iron", "Gems"]:
		var hb = $Harvest/HarvestOptions/VBoxContainer/HBoxContainer.get_node(r).get_node("Button")
		#var count = get_node("Common/ResourcesPanel/Player/%s/Label" % r).text
		#print(count)
		#ho.get_node("Button").text = "Harvest [%s] (+%d)" % [r, 0]
		hb.connect("pressed", self, "_on_Harvest_Button_pressed", [r, hb])


func _process(delta):
	$Common/CurrentPhase.text = ag.phase + " PHASE"
	
	if ag.phase == "BUY_CARD":
		ProcessBuyCard()
	elif ag.phase == "PLACE_CARD":
		ProcessPlaceCard()
	elif ag.phase == "ACTION":
		ProcessAction()


func ProcessBuyCard():
	pass

func ProcessPlaceCard():
	if $PlaceCard/Timer.time_left <= 0.0:
		var tm = ag.get_node("World/Tilemaps/TileMap")
		var mPos = tm.get_local_mouse_position()
		var coords = tm.world_to_map(mPos)
		
		var tmPlace = ag.get_node("World/Tilemaps/UnitPlacement")
		
		if Input.is_action_just_pressed("left_click") and tmPlace.get_cellv(coords) == 0:
			print("Selecting tile")
			SelectTile(coords)
			$PlaceCard/Timer.start()
		
		if Input.is_action_just_pressed("rotate_left"):
			ag.get_node("World/VFX/PlaceUnitIndicator").Rotate(-1)
		elif Input.is_action_just_pressed("rotate_right"):
			ag.get_node("World/VFX/PlaceUnitIndicator").Rotate(1)


func ProcessAction():
	$Action/TimerBar.value = ag.get_node("Timer").time_left
	$Action/TimerBar/Label.text = "%.2f" % stepify(ag.get_node("Timer").time_left, 0.01)
	
	UpdateResourcesPanel()


func ActivateHarvest():
	$Action.hide()
	
	$Harvest.show()
	
	$Common/ResourcesPanel.margin_left = -384
	
	pass

func ActivateBuyCard():
	# close out Action UI
	$Harvest.hide()
	
	$BuyCard.show()
	
	$Common/CardsPanel.margin_right = 256
	$Common/ResourcesPanel.margin_left = -384
	
	UpdateCards()
	UpdateResourcesPanel()

func ActivatePlaceCard():
	$BuyCard.hide()
	
	$Common/CardsPanel.margin_right = 128
	$Common/ResourcesPanel.margin_left = -256
	
	for co in $Common/CardsPanel/VBoxContainer.get_children():
		var button = co.get_node("Button")
		button.disabled = true
	
	UpdateResourcesPanel()
	
	if playerSelection:
	
		# initialize player validity map
		var bestY = 9999
		for ui in ag.get_node("World/Units").get_children():
			if ui.unitTeam == 0 and ui.coords.y < bestY:
				bestY = ui.coords.y
		bestY -= 1
		
		var tmTerrain = ag.get_node("World/Tilemaps/TileMap")
		var tmUnits = ag.get_node("World/Tilemaps/Units")
		var tmPlace = ag.get_node("World/Tilemaps/UnitPlacement")
		for v in tmTerrain.get_used_cells():
			if v.y >= bestY and tmTerrain.get_cellv(v) in [1] and tmUnits.get_cellv(v) == -1:
				tmPlace.set_cellv(v, 0)
	
		var pui = PlaceUnitIndicator.instance()
		get_parent().get_node("World/VFX").add_child(pui)
		pui.Activate(playerSelection)
	
	else:
		if opponentSelection:
			OpponentPlaceUnit()
		
		ag.EnterAction()
	#elif opponentSelection:
	#	OpponentPlaceUnit()
	#	ag.EnterAction()

func ActivateAction():
	$Action.show()
	
	UpdateCards()
	UpdateResourcesPanel()


func UpdateResourcesPanel():
	var harvests = [
		{"Food": 1, "Wood": 1, "Iron": 1, "Gems": 1},
		{"Food": 1, "Wood": 1, "Iron": 1, "Gems": 1}
		]
	for ui in ag.get_node("World/Units").get_children():
		if ui.unitType == "peasant":
			var terrain = ui.GetTerrain()
			if terrain:
				var terrainInfo = Database.tiles[terrain]
				if "resource" in terrainInfo:
					var resource = terrainInfo["resource"]
					harvests[ui.unitTeam][resource] += 1
	
	for r in ["Food", "Wood", "Iron", "Gems"]:
		var count = ag.playerResources[r]
		var harvestCount = harvests[0][r]
		get_node("Common/ResourcesPanel/Player/" + r).get_node("Label").text = "%d (%d)" % [count, harvestCount]
		
		count = ag.opponentResources[r]
		harvestCount = harvests[1][r]
		get_node("Common/ResourcesPanel/Opponent/" + r).get_node("Label").text = "%d (%d)" % [count, harvestCount]


func UpdateCards():
	var i = 1
	for co in $Common/CardsPanel/VBoxContainer.get_children():
		co.get_node("Label").text = ag.activeCards[i]
		
		var button = co.get_node("Button")
		
		# card button textures
		var unitTileId = ag.get_node("World/Tilemaps/Units").tile_set.find_tile_by_name(ag.activeCards[i])
		var unitTextureRegion = ag.get_node("World/Tilemaps/Units").tile_set.tile_get_region(unitTileId)
		var unitTexture = unitsTexture.duplicate()
		co.get_node("Button/TextureRect").texture = unitTexture
		co.get_node("Button/TextureRect").texture.region = unitTextureRegion
		
		# card costs
		var costs = Database.cards[ag.activeCards[i]]["cost"]
		for r in ["Food", "Wood", "Iron", "Gems"]:
			if r in costs:
				co.get_node("Costs/" + r).show()
				co.get_node("Costs/" + r + "/Label").text = str(costs[r])
			else:
				co.get_node("Costs/" + r).hide()
		
		button.disabled = false
		for r in costs:
			if costs[r] > ag.playerResources[r]:
				button.disabled = true
		
		i += 1


func SelectHarvest(r):
	var harvests = [
		{"Food": 1, "Wood": 1, "Iron": 1, "Gems": 1},
		{"Food": 1, "Wood": 1, "Iron": 1, "Gems": 1}
		]
	for ui in ag.get_node("World/Units").get_children():
		if ui.unitType == "peasant":
			var terrain = ui.GetTerrain()
			if terrain:
				var terrainInfo = Database.tiles[terrain]
				if "resource" in terrainInfo:
					var resource = terrainInfo["resource"]
					harvests[ui.unitTeam][resource] += 1
	
	ag.playerResources[r] += harvests[0][r]
	
	# opponent pick
	var oppHarvest = ag.get_node("AI").PickHarvest()
	ag.opponentResources[oppHarvest] += harvests[1][oppHarvest]
	
	UpdateResourcesPanel()
	ag.EnterBuyCard()

func SelectCard(i):
	playerSelectionIx = i
	playerSelection = ""
	
	if i == -1:  # player passed
		pass
	
	else:  # player picked card
		playerSelection = ag.activeCards[i]
		var costs = Database.cards[ag.activeCards[i]]["cost"]
		for r in costs:
			ag.playerResources[r] -= costs[r]
	
	# opponent picks card
	opponentSelectionIx = ag.get_node("AI").PickCard(i)
	opponentSelection = ""
	
	if opponentSelectionIx == -1:
		pass
	else:
		opponentSelection = ag.activeCards[opponentSelectionIx]
	
		print("Opponent picks card %d" % opponentSelectionIx)
		var costs = Database.cards[ag.activeCards[opponentSelectionIx]]["cost"]
		for r in costs:
			ag.opponentResources[r] -= costs[r]
	
		for co in $Common/CardsPanel/VBoxContainer.get_children():
			co.get_node("Button").disabled = true
	
	UpdateResourcesPanel()
	
	$BuyCard/Timer.start()

func SelectTile(coords):
	var pui = ag.get_node("World/VFX/PlaceUnitIndicator")
	
	ag.SpawnUnit(playerSelection, coords, 0, pui.unitDir)
	pui.queue_free()
	ag.get_node("World/Tilemaps/UnitPlacement").clear()
	
	if opponentSelection:
		OpponentPlaceUnit()

func OpponentPlaceUnit():
	var vDir = ag.get_node("AI").PickTile(opponentSelection)
	#ag.SpawnUnit(opponentSelection, ag.get_node("AI").PickTile(opponentSelection), 1, 2)
	ag.SpawnUnit(opponentSelection, vDir[0], 1, vDir[1])
	ag.get_node("World/Tilemaps/UnitPlacement").clear()


func _on_CardOption_mouse_entered(i):
	if ag.phase == "BUY_CARD":
		print("Card Option %d hovered" % i)
		
		var cardName = ag.activeCards[i]
		var cardInfo = Database.cards[cardName]
		var desc = cardInfo["description"]
		
		#$Common/CardDetails/Label.text = desc
	
	#$Common/CardsPanel/VBoxContainer.get_node("CardOption%d" % i).get_node("Inspector").show()

func _on_CardOptionButton_mouse_entered(co):
	co.get_node("Inspector").show()

func _on_CardOptionButton_mouse_exited(co):
	co.get_node("Inspector").hide()

func _on_CardOptionButton_pressed(i):
	print("Card Number %d pressed" % i)
	SelectCard(i)


func _on_PassButton_pressed():
	SelectCard(-1)

func _on_BuyCard_Timer_timeout():
	ag.EnterPlaceCard()

func _on_PlaceCard_Timer_timeout():
	ag.EnterAction()

func _on_Harvest_Button_pressed(r, hb):
	SelectHarvest(r)
