extends Node


var ag


func _ready():
	pass


func Activate():
	ag = get_node("/root/ActiveGame")


func Cast(ui, spell):
	print(ui.unitName, " casts ", spell)
	call(spell, ui)


func Piercing_Bolt(ui):
	var aoeMap = [
		Vector2(0, -1),
		Vector2(0, -2),
	]
	
	# todo: handle team
	
	ag.SpawnAOEEffect(ui.coords, aoeMap, "Damage", "ActiveGame/Art/Attacks/PiercingBolt.png")
	ag.CheckAOE_v2(ui.coords, aoeMap, "attack", {"attack": ui.attack, "isMagic": true})

func Healing_Aura(ui):
	var aoeMap = [
		Vector2(-1, -1),
		Vector2(0, -1),
		Vector2(1, -1),
		Vector2(-1, 0),
		Vector2(1, 0),
		Vector2(-1, 1),
		Vector2(0, 1),
		Vector2(1, 1)
	]
	
	# todo: handle team
	
	ag.SpawnAOEEffect(ui.coords, aoeMap, "Heal", "ActiveGame/Art/Attacks/Heal.png")
	ag.CheckAOE_v2(ui.coords, aoeMap, "heal", {"heal": 2})

func Fireball(ui):
	var aoeMap = [
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
	
	# todo: handle team
	
	ag.SpawnAOEEffect(ui.coords, aoeMap, "Damage", "ActiveGame/Art/Attacks/Fireball.png")
	ag.CheckAOE_v2(ui.coords, aoeMap, "attack", {"attack": ui.attack, "isMagic": true})
