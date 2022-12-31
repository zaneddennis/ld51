extends CanvasLayer


onready var unitsTexture = AtlasTexture.new()


func _ready():
	unitsTexture.atlas = load("res://ActiveGame/Art/Tiles/Units.png")
	
	$AudioStreamPlayer.play()


func _on_StartGame_pressed():
	get_tree().change_scene("res://ActiveGame/ActiveGame.tscn")


func _on_ExitToDesktop_pressed():
	get_tree().quit()


func _on_FlipTimer_timeout():	
	var i = 1 + randi()%16
	var tr = get_node("Background/Content/GridContainer/Card%d/Unit" % i)
	
	var newUnitName = Util.Choice(Database.cards.keys())
	var textureLoc = Database.cards[newUnitName]["texture"] * 64
	
	print(newUnitName)
	tr.texture = unitsTexture.duplicate()
	tr.texture.region = Rect2(textureLoc, Vector2(64, 64))
