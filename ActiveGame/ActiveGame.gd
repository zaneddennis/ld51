extends Node


var UnitInstance = preload("res://ActiveGame/UnitInstance.tscn")
var FadingAlert = preload("res://ActiveGame/UI/FadingAlert.tscn")
var AOE = preload("res://ActiveGame/UI/AOE.tscn")

onready var unitsTexture = AtlasTexture.new()


var phase = ""

var activeCards = {
	1: "Peasant",
	2: "Peasant",
	3: "Peasant",
	4: "Peasant"
}

var playerResources = {
	"Food": 3,
	"Wood": 3,
	"Iron": 3,
	"Gems": 3
}

var opponentResources = {
	"Food": 3,
	"Wood": 3,
	"Iron": 3,
	"Gems": 3
}


func _ready():
	randomize()
	
	unitsTexture.atlas = load("res://ActiveGame/Art/Tiles/Units.png")
	
	Spells.Activate()
	
	EnterBuyCard()
	
	for tId in $World/Tilemaps/Units.tile_set.get_tiles_ids():
		print("  %d - %s" % [tId, $World/Tilemaps/Units.tile_set.tile_get_name(tId)])


func EnterHarvest():
	print("Entering HARVEST phase")
	phase = "HARVEST"
	$UI.ActivateHarvest()

func EnterBuyCard():
	print("Entering BUY_CARD phase")
	phase = "BUY_CARD"
	$UI.ActivateBuyCard()

func EnterPlaceCard():
	print("Entering PLACE_CARD phase")
	phase = "PLACE_CARD"
	$UI.ActivatePlaceCard()

func EnterAction():
	print("Entering ACTION phase")
	phase = "ACTION"
	
	for ix in [$UI.playerSelectionIx, $UI.opponentSelectionIx]:
		if ix != 4 and ix != -1:
			activeCards[ix] = Database.DrawCard()
	
	$UI.ActivateAction()
	
	$Timer.start()


func EnterGameOver(result):
	$Timer.stop()
	
	print("Entering GAME_OVER phase")
	phase = "GAME_OVER"
	
	$UI/GameOver/Panel/Title.text = "YOU HAVE " + result
	
	var summary = "Evil has been vanquished, and the citizens of the land shall live happily ever after."
	if result == "LOST":
		summary = "Evil reigns over the land, and the poets sing great lamentations."
	
	$UI/GameOver/Panel/Summary.text = summary
	
	$UI/GameOver.show()


func SpawnUnit(unitName, coords, team=0, dir=0):
	var tm = get_node("World/Tilemaps/Units")
	var unitTileId = tm.tile_set.find_tile_by_name(unitName)
	tm.set_cellv(coords, unitTileId)
	
	var ui = UnitInstance.instance()
	$World/Units.add_child(ui)
	ui.unitName = unitName
	ui.unitTeam = team
	ui.coords = coords
	ui.unitDir = dir
	ui.Activate()

func SpawnFadingAlert(coords, text="", color="", spritePath="", dir=0):
	var fa = FadingAlert.instance()
	$World.add_child(fa)
	fa.position = (coords * 64) + Vector2(32, 32)
	
	fa.get_node("Label").text = text
	
	if color:
		fa.get_node("Label").add_color_override("font_color", ColorN(color))
	
	if spritePath:
		fa.get_node("Sprite").texture = load("res://" + spritePath)
		fa.get_node("Sprite").rotation = dir * (PI/2)

func SpawnAOEEffect(coords, map, effect="Damage", spritepath="", dir=0):
	var aoe = AOE.instance()
	$World.add_child(aoe)
	aoe.position = (coords * 64)
	
	for v in map:
		var tileId = aoe.get_node("TileMap").tile_set.find_tile_by_name(effect)
		aoe.get_node("TileMap").set_cellv(v, tileId)
		if spritepath:
			SpawnFadingAlert(coords + v, "", "", spritepath, dir)


func CheckAOE_v2(coords, map, action, actionParams):
	for v in map:
		var coord = (coords + v).round()
		if $World/Tilemaps/Units.get_cellv(coord) != -1:
			var unit = null
			for ui in $World/Units.get_children():
				if ui.coords == coord:
					unit = ui
					break
			assert(unit != null)
			print("apply action to ", unit)
			
			match action:
				"attack": unit.Attacked(actionParams["attack"], actionParams["isMagic"])
				
				"heal": unit.Heal(actionParams["heal"])
				
				_: assert(false)

func CheckForUnit(coord):
	var unit = null
	for ui in $World/Units.get_children():
		if ui.coords == coord:
			unit = ui
			break
	return unit


func _on_Timer_timeout():
	print("Timer timeout")
	
	if phase == "ACTION":
		#EnterBuyCard()
		EnterHarvest()
