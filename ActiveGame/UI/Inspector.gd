extends Control


onready var ag = get_node("/root/ActiveGame")
onready var tilemaps = get_node("/root/ActiveGame/World/Tilemaps")
onready var cardOptions = get_node("/root/ActiveGame/UI/Common/CardsPanel/VBoxContainer")

onready var tilesetBase = tilemaps.get_node("TileMap").tile_set
onready var tilesetBonus = tilemaps.get_node("Bonus").tile_set
onready var tilesetUnits = tilemaps.get_node("Units").tile_set

onready var tileInspector = $"../../World/VFX/TileInspector"


func _ready():
	pass

func _process(delta):
	ProcessUnitDetails()


func ProcessUnitDetails():
	HideUnit()
	
	var isOverCard = false
	var i = 1
	for co in cardOptions.get_children():
		if co.get_node("Inspector").visible:
			var unitName = ag.activeCards[i]
			ShowUnit(unitName)
			isOverCard = true
			break
		
		i += 1
	
	if not isOverCard:
		var unit = tilemaps.get_node("Units").get_cellv(tileInspector.coord)
		if unit != -1:
			var unitName = tilesetUnits.tile_get_name(unit)
			ShowUnit(unitName)
		


func ShowTerrain(base, bonus):
	var tileName = tilesetBase.tile_get_name(base)
	if bonus != -1:
		tileName = tilesetBonus.tile_get_name(bonus)
	
	$Terrain/Label.text = "[%s] %s" % [
		tileName,
		Database.tiles[tileName]["details"]]
	
	$Terrain.show()

func HideTerrain():
	$Terrain.hide()

func ShowUnit(unitName):
	var unitInfo = Database.cards[unitName]
	
	$Unit/Label.text = "[%s] %s" % [
		unitName,
		unitInfo["description"]
	] + "\nHP: %d | ACT SPD: %.2f/sec | ATT: %d | DEF: %d" % [
		unitInfo["maxHP"],
		unitInfo["actionSpeed"],
		unitInfo["attack"],
		unitInfo["defense"]
	]
	
	$Unit/Quote_Label.text = "\"%s\"" % unitInfo["quote"]
	
	$Unit.show()

func HideUnit():
	$Unit.hide()
