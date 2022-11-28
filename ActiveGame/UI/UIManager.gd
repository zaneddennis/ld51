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
		co.get_node("Button").connect("pressed", self, "_on_CardOptionButton_pressed", [i])

func _process(delta):
	$Common/CurrentPhase.text = ag.phase + " PHASE"
	
	if ag.phase == "BUY_CARD":
		ProcessBuyCard()
	elif ag.phase == "PLACE_CARD":
		ProcessPlaceCard()
	elif ag.phase == "ACTION":
		ProcessAction()


func ProcessBuyCard():
	if $Common/CardsPanel.get_local_mouse_position().x < $Common/CardsPanel.margin_right:
		$Common/CardDetails.show()
	else:
		$Common/CardDetails.hide()

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


func ProcessAction():
	$Action/TimerBar.value = ag.get_node("Timer").time_left
	$Action/TimerBar/Label.text = "%.2f" % stepify(ag.get_node("Timer").time_left, 0.01)
	
	UpdateResourcesPanel()


func ActivateBuyCard():
	# close out Action UI
	$Action.hide()
	
	$BuyCard.show()
	
	$Common/CardsPanel.margin_right = 256
	$Common/ResourcesPanel.margin_left = -256
	
	UpdateCards()
	UpdateResourcesPanel()

func ActivatePlaceCard():
	$BuyCard.hide()
	
	$Common/CardsPanel.margin_right = 128
	$Common/ResourcesPanel.margin_left = -128
	
	for co in $Common/CardsPanel/VBoxContainer.get_children():
		var button = co.get_node("Button")
		button.disabled = true
	
	UpdateResourcesPanel()
	
	if playerSelection:
		$Common/CardDetails/Label.text = Database.cards[playerSelection]["description"]
		$Common/CardDetails.show()
	
	
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
	
	elif opponentSelection:
		OpponentPlaceUnit()
		ag.EnterAction()

func ActivateAction():
	$Action.show()
	
	UpdateCards()
	UpdateResourcesPanel()


func UpdateResourcesPanel():
	for r in ["Food", "Wood", "Iron", "Gems"]:
		var count = ag.playerResources[r]
		get_node("Common/ResourcesPanel/VBoxContainer/" + r).get_node("Label").text = str(count)
		
		var oppCount = ag.opponentResources[r]
		get_node("Common/ResourcesPanel/VBoxContainer/" + r).get_node("OppLabel").text = "Opponent: " + str(oppCount)

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
				#button.modulate = Color("afafaf")
		
		i += 1


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
	var c = i
	while c == i:
		c = 1 + randi() % 3
	opponentSelectionIx = c
	opponentSelection = ag.activeCards[c]
	
	print("Opponent picks card %d" % c)
	print("Opponent picks card %d" % c)
	var costs = Database.cards[ag.activeCards[c]]["cost"]
	for r in costs:
		ag.opponentResources[r] -= costs[r]
	
	for co in $Common/CardsPanel/VBoxContainer.get_children():
		co.get_node("Button").disabled = true
	
	UpdateResourcesPanel()
	
	$BuyCard/Timer.start()

func SelectTile(coords):
	#var up = ag.get_node("World/Tilemaps/UnitPlacement")
	#if up.get_cellv(coords) == 0:  # if tile is valid for unit placement
	ag.SpawnUnit(playerSelection, coords)
	ag.get_node("World/VFX/PlaceUnitIndicator").queue_free()
	ag.get_node("World/Tilemaps/UnitPlacement").clear()
	
	"""# opponent validity map
	var bestY = 0
	for ui in ag.get_node("World/Units").get_children():
		if ui.unitTeam == 1 and ui.coords.y > bestY:
			bestY = ui.coords.y
	bestY += 1
	
	var tmTerrain = ag.get_node("World/Tilemaps/TileMap")
	var tmUnits = ag.get_node("World/Tilemaps/Units")
	
	# opponent place unit
	var oCoords = Vector2(randi()%16, randi()%16)
	while oCoords.y > bestY:
		oCoords = Vector2(randi()%16, randi()%16)
	print("Opponent places at ", oCoords)
	ag.SpawnUnit(opponentSelection, oCoords, 1)
	
	# todo: VFX highlight"""
	
	OpponentPlaceUnit()

func OpponentPlaceUnit():
	# opponent validity map
	var bestY = 0
	for ui in ag.get_node("World/Units").get_children():
		if ui.unitTeam == 1 and ui.coords.y > bestY:
			bestY = ui.coords.y
	bestY += 1
	
	var tmTerrain = ag.get_node("World/Tilemaps/TileMap")
	var tmUnits = ag.get_node("World/Tilemaps/Units")
	var tmPlace = ag.get_node("World/Tilemaps/UnitPlacement")
	for v in tmTerrain.get_used_cells():
		if v.y <= bestY and tmTerrain.get_cellv(v) in [1] and tmUnits.get_cellv(v) == -1:
			tmPlace.set_cellv(v, 0)
	
	# choose opponent place location
	var coords = Vector2(randi()%16, randi()%int(bestY+1))
	while tmPlace.get_cellv(coords) != 0:  # if bad selection, try again
		coords = Vector2(randi()%16, randi()%int(bestY+1))
	
	# place opponent unit
	tmPlace.clear()
	ag.SpawnUnit(opponentSelection, coords, 1)


func _on_CardOption_mouse_entered(i):
	if ag.phase == "BUY_CARD":
		print("Card Option %d hovered" % i)
		
		var cardName = ag.activeCards[i]
		var cardInfo = Database.cards[cardName]
		var desc = cardInfo["description"]
		
		$Common/CardDetails/Label.text = desc

func _on_CardOptionButton_pressed(i):
	print("Card Number %d pressed" % i)
	SelectCard(i)


func _on_PassButton_pressed():
	SelectCard(-1)


func _on_BuyCard_Timer_timeout():
	ag.EnterPlaceCard()


func _on_PlaceCard_Timer_timeout():
	ag.EnterAction()
