extends Node2D


var Projectile = preload("res://ActiveGame/Projectile.tscn")


onready var ag = get_node("/root/ActiveGame")


export var unitName = ""
export var unitTeam = 0
export var unitDir = 0  # quarter turns clockwise past 0,-1

var unitType = ""

var hp = 0
var maxHp = 0
export var coords = Vector2(0, 0)

var actionSpeed = 0.0  # actions per second
var actionTime = 0.0
var actionProgress = 0.0

var attack = 0
var defense = 0

var maxRange = 0


func _ready():
	Activate()

func _process(delta):
	if ag.phase == "ACTION":
		$HPBar.value = hp
		
		if unitType == "peasant":
			#ProcessPeasant(delta)
			pass
		
		elif unitType in ["projectile", "melee", "mage"]:
			ProcessSoldier(delta)
		
		elif unitType == "structure":
			#ProcessStructure(delta)
			pass
		
		else:
			assert(false)


func ProcessPeasant(delta):
	var tm_bonus = get_node("/root/ActiveGame/World/Tilemaps/Bonus")
	var tId = tm_bonus.get_cellv(coords)
	var terrain = tm_bonus.tile_set.tile_get_name(tId)
	
	if terrain in ["Farm", "Forest", "Iron Deposit", "Gems Deposit"]:
		actionProgress += delta
		$ActionProgress.value = actionProgress
		
		if actionProgress >= actionTime:
			Harvest(terrain)
			actionProgress = 0.0

func ProcessSoldier(delta):
	actionProgress += delta
	$ActionProgress.value = actionProgress
	
	if actionProgress >= actionTime:
		if unitType == "projectile":
			Shoot()
		elif unitType == "melee":
			Hit()
		elif unitType == "mage":
			Cast()
		actionProgress = 0.0

func ProcessStructure(delta):
	actionProgress += delta
	$ActionProgress.value = actionProgress
	
	if actionProgress >= actionTime and unitName == "Keep":
		for r in ["Food", "Wood", "Iron", "Gems"]:
			if unitTeam == 0:
				ag.playerResources[r] += 1
			
			else:
				ag.opponentResources[r] += 1
		
		if unitTeam == 0:
			ag.SpawnFadingAlert(coords, "+1 All Resources", "blue")
		else:
			ag.SpawnFadingAlert(coords, "+1 All Resources", "red")
		
		actionProgress = 0.0


func Harvest(terrain):
	var resource = {
		"Farm": "Food",
		"Forest": "Wood",
		"Iron Deposit": "Iron",
		"Gems Deposit": "Gems"
	}[terrain]
	
	if unitTeam == 0:
		ag.playerResources[resource] += 1
		ag.SpawnFadingAlert(coords, "+1 %s" % resource, "blue")
	
	else:
		ag.opponentResources[resource] += 1
		ag.SpawnFadingAlert(coords, "+1 %s" % resource, "red")

# fire ranged weapon
func Shoot():
	var effAttack = attack
	
	var bt = ag.get_node("World/Tilemaps/Bonus").get_cellv(coords)
	if bt == 4:
		effAttack += 1
	
	var p = Projectile.instance()
	get_node("/root/ActiveGame/World/Projectiles").add_child(p)
	p.Activate(position, unitDir, maxRange, effAttack)

# swing melee weapon
func Hit():
	var aoeMap = Database.cards[unitName]["aoeMap"].duplicate(true)
	var attackTexture = Database.cards[unitName]["attackTexture"]
	
	aoeMap = Util.TransformAOEMap(aoeMap, unitDir)
	
	ag.SpawnAOEEffect(coords, aoeMap, "Damage", "ActiveGame/Art/Attacks/%s" % attackTexture, unitDir)
	ag.CheckAOE_v2(coords, aoeMap, "attack", {"attack": attack, "isMagic": false})

func Cast():
	var spell = Database.cards[unitName]["spell"]
	
	Spells.Cast(self, spell)


func Attacked(att, isMagic):
	var damage = att
	var effDefense = defense
	
	var bt = ag.get_node("World/Tilemaps/Bonus").get_cellv(coords)
	if bt == 1:  # forest
		effDefense += 1
	elif bt == 5:  # mountain
		effDefense += 2
	
	if not isMagic:
		#damage = max(1, round(att/effDefense))
		
		if att < effDefense - 2:
			damage = max(int(4 - (effDefense - 2 - att)), 1)
		
		elif att > effDefense + 4:
			damage = max(int(7 + (att - (effDefense + 4))/4), 1)
		
		else:
			damage = max(int(5 + (att - effDefense)/2), 1)
		
	print(unitName, " is hit! From %d Attack and %d Defense, suffers %d damage." % [att, effDefense, damage])
	TakeDamage(damage)


func TakeDamage(damage):
	hp -= damage
	
	ag.SpawnFadingAlert(coords, "-%d" % damage, "red")
	
	if hp <= 0:
		print(unitName, " dies!")
		
		var tm = get_node("/root/ActiveGame/World/Tilemaps/Units")
		tm.set_cellv(coords, -1)
		queue_free()
		
		if unitName == "Keep":
			if unitTeam == 0:
				ag.EnterGameOver("LOST")
			elif unitTeam == 1:
				ag.EnterGameOver("WON")
			else:
				assert(false)


func Heal(damage):
	#hp = clamp(hp + damage, hp, maxHp)
	
	#ag.SpawnFadingAlert(coords, "+%d" % damage, "green")
	
	if hp + damage >= maxHp:
		ag.SpawnFadingAlert(coords, "+%d" % (maxHp - hp), "green")
		hp = maxHp
	else:
		hp += damage
		ag.SpawnFadingAlert(coords, "+%d" % damage, "green")


func Activate():
	position = coords * 64 + Vector2(32, 32)
	
	$Sprite.region_rect = Rect2(Vector2(64, 0) * unitTeam, Vector2(64, 64))
	$Sprite.rotation = (PI/2) * unitDir
	
	var unitInfo = Database.cards[unitName]
	
	unitType = unitInfo["unitType"]
	
	maxHp = unitInfo["maxHP"]
	$HPBar.max_value = maxHp
	$HPBar.value = hp
	
	hp = maxHp
	defense = unitInfo["defense"]
	
	if unitType == "projectile":
		maxRange = unitInfo["maxRange"]
	
	if unitType != "structure" and unitType != "peasant":
		actionSpeed = unitInfo["actionSpeed"]
		actionTime = 1.0 / actionSpeed
		
		attack = unitInfo["attack"]
		
		$ActionProgress.max_value = actionTime
		$ActionProgress.value = 0.0
		$ActionProgress.show()
	else:
		$ActionProgress.hide()


func GetTerrain():
	var tm_bonus = get_node("/root/ActiveGame/World/Tilemaps/Bonus")
	var tId = tm_bonus.get_cellv(coords)
	return tm_bonus.tile_set.tile_get_name(tId)
