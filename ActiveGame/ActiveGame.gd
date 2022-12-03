extends Node


var UnitInstance = preload("res://ActiveGame/UnitInstance.tscn")
var FadingAlert = preload("res://ActiveGame/UI/FadingAlert.tscn")
var AOE = preload("res://ActiveGame/UI/AOE.tscn")

onready var unitsTexture = AtlasTexture.new()


var phase = ""

var activeCards = {
	1: "Peasant",
	2: "Spearman",
	3: "Archer",
	4: "Peasant"
}

var playerResources = {
	"Food": 10,
	"Wood": 5,
	"Iron": 5,
	"Gems": 5
}

var opponentResources = {
	"Food": 5,
	"Wood": 5,
	"Iron": 5,
	"Gems": 5
}


func _ready():
	randomize()
	
	unitsTexture.atlas = load("res://ActiveGame/Art/Tiles/Units.png")
	
	Spells.Activate()
	
	EnterBuyCard()


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
		if ix != 4:
			activeCards[ix] = Database.DrawCard()
	
	$UI.ActivateAction()
	
	$Timer.start()


func EnterGameOver(result):
	$Timer.stop()
	
	print("Entering GAME_OVER phase")
	phase = "GAME_OVER"
	
	$UI/GameOver/Panel/Title.text = "YOU HAVE " + result
	
	$UI/GameOver.show()

#func ClearPhase():
#	for p in $UI.get_children():
#		p.hide()


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


func CheckAOE_OLD(coords, map, attack, isMagic=false):
	for v in map:
		var coord = coords + v
		if $World/Tilemaps/Units.get_cellv(coord) != -1:
			var unit = null
			for ui in $World/Units.get_children():
				if ui.coords == coord:
					unit = ui
					break
			assert(unit != null)
			unit.Attacked(attack, isMagic)

func CheckAOE_v2(coords, map, action, actionParams):
	for v in map:
		var coord = coords + v
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


func _on_Timer_timeout():
	print("Timer timeout")
	
	if phase == "ACTION":
		EnterBuyCard()
