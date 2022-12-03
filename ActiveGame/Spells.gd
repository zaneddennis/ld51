extends Node


var ag

var maps = {
	"Piercing_Bolt": [
		Vector2(0, -1),
		Vector2(0, -2),
	],
	
	"Healing_Aura": [
		Vector2(-1, -1),
		Vector2(0, -1),
		Vector2(1, -1),
		Vector2(-1, 0),
		Vector2(1, 0),
		Vector2(-1, 1),
		Vector2(0, 1),
		Vector2(1, 1)
	],
	
	"Fireball": [
		Vector2(-1, -1),
		Vector2(0, -1),
		Vector2(1, -1),
		Vector2(-1, -2),
		Vector2(0, -2),
		Vector2(1, -2),
		Vector2(-1, -3),
		Vector2(0, -3),
		Vector2(1, -3),
	]
}


func _ready():
	pass


func Activate():
	ag = get_node("/root/ActiveGame")


func Cast(ui, spell):
	print(ui.unitName, " casts ", spell)
	call(spell, ui)


func Piercing_Bolt(ui):
	#var aoeMap = [
	#	Vector2(0, -1),
	#	Vector2(0, -2),
	#]
	var aoeMap = maps["Piercing_Bolt"]
	
	aoeMap = Util.TransformAOEMap(aoeMap, ui.unitDir)
	
	ag.SpawnAOEEffect(ui.coords, aoeMap, "Damage", "ActiveGame/Art/Attacks/PiercingBolt.png", ui.unitDir)
	ag.CheckAOE_v2(ui.coords, aoeMap, "attack", {"attack": ui.attack, "isMagic": true})

func Healing_Aura(ui):
	#var aoeMap = [
	#	Vector2(-1, -1),
	#	Vector2(0, -1),
	#	Vector2(1, -1),
	#	Vector2(-1, 0),
	#	Vector2(1, 0),
	#	Vector2(-1, 1),
	#	Vector2(0, 1),
	#	Vector2(1, 1)
	#
	var aoeMap = maps["Healing_Aura"]
	
	# doesn't need to handle direction cause it's a circle
	
	ag.SpawnAOEEffect(ui.coords, aoeMap, "Heal", "ActiveGame/Art/Attacks/Heal.png")
	ag.CheckAOE_v2(ui.coords, aoeMap, "heal", {"heal": 2})

func Fireball(ui):
	#var aoeMap = [
	#	Vector2(-1, -1),
	#	Vector2(0, -1),
	#	Vector2(1, -1),
	#	Vector2(-1, -2),
	#	Vector2(0, -2),
	#	Vector2(1, -2),
	#	Vector2(-1, -3),
	#	Vector2(0, -3),
	#	Vector2(1, -3),
	#]
	var aoeMap = maps["Fireball"]
	aoeMap = Util.TransformAOEMap(aoeMap, ui.unitDir)
	
	ag.SpawnAOEEffect(ui.coords, aoeMap, "Damage", "ActiveGame/Art/Attacks/Fireball.png")
	ag.CheckAOE_v2(ui.coords, aoeMap, "attack", {"attack": ui.attack, "isMagic": true})
