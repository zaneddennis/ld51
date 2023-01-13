extends Node


# reference
var bt2Resource = {
	"Farm": "Food",
	"Forest": "Wood",
	"Iron Deposit": "Iron",
	"Gems Deposit": "Gems"
}

var res2Bt = {
	"Food": "Farm",
	"Wood": "Forest",
	"Iron": "Iron Deposit",
	"Gems": "Gems Deposit"
}


# cards
var cards = {
	"Peasant": {
		"frequency": 6,
		"description": "Harvests Resources from Farm, Forest, Iron, and Gems tiles.",
		"quote": "It takes an army to equip an army with tools and weapons. Others say an army fights on its stomach. Either way, someone has to make that stuff.",
		"unitType": "peasant",
		"texture": Vector2(0, 1),
		"cost": {
			"Food": 6,
			"Wood": 2
		},
		
		"maxHP": 4,
		"actionSpeed": 0.25,
		"attack": 0,
		"defense": 3,
	},
	"Archer": {
		"frequency": 8,
		"description": "Shoots arrows in a straight line.",
		"quote": "All it takes to kill a man is one arrow. Or five. Or twenty. The aiming is the hard part.",
		"unitType": "projectile",
		"texture": Vector2(0, 2),
		"cost": {
			"Food": 10,
			"Wood": 6
		},
		
		"maxHP": 6,
		"actionSpeed": 0.3,
		"attack": 7,
		"defense": 4,
		
		"maxRange": 2
	},
	"Spearman": {
		"frequency": 8,
		"description": "Stabs a spear one tile forward. Deals low damage but has higher defense.",
		"quote": "Step 1: Direct pointy end towards enemy. Step 2: Stab. Step 3: ??? Step 4: Profit.",
		"unitType": "melee",
		"texture": Vector2(1, 2),
		"cost": {
			"Food": 8,
			"Wood": 2,
			"Iron": 4
		},
		
		"maxHP": 10,
		"actionSpeed": 0.2,
		"attack": 5,
		"defense": 6,
		
		"attackTexture": "Sword.png",
		"aoeMap": [Vector2(0, -1)]
	},
	"Pikeman": {
		"frequency": 4,
		"description": "Better Spearman with improved range, attack, and defense.",
		"quote": "A cut above your average spearman. Or should that be a stab above?",
		"unitType": "melee",
		"texture": Vector2(2, 2),
		"cost": {
			"Food": 12,
			"Wood": 2,
			"Iron": 12
		},
		
		"maxHP": 16,
		"actionSpeed": 0.35,
		"attack": 6,
		"defense": 9,
		
		"attackTexture": "Sword.png",
		"aoeMap": [Vector2(0, -1), Vector2(0, -2)]
	},
	"Longbowman": {
		"frequency": 4,
		"description": "Better Archer with improved range and significantly improved damage.",
		"quote": "'What if we took a bow and made it *bigger*?' - the first Longbowman",
		"unitType": "projectile",
		"texture": Vector2(4, 2),
		"cost": {
			"Food": 14,
			"Wood": 10,
			"Iron": 6
		},
		
		"maxHP": 8,
		"actionSpeed": 0.4,
		"attack": 15,
		"defense": 6,
		
		"maxRange": 4,
	},
	"Swordsman": {
		"frequency": 4,
		"description": "Sweeps sword in a cone. Medium stats in all regards.",
		"quote": "Some say that a sword is for slashing. Others say it's for stabbing. A real Swordsman knows that the true purpose of a well-crafted sword is showing it off to everyone at the tavern.",
		"unitType": "melee",
		"texture": Vector2(3, 2),
		"cost": {
			"Food": 16,
			"Iron": 16
		},
		
		"maxHP": 14,
		"actionSpeed": 0.3,
		"attack": 8,
		"defense": 10,
		
		"attackTexture": "Sword.png",
		"aoeMap": [Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]
	},
	"Acolyte": {
		"frequency": 4,
		"description": "Fragile Mage that casts spell with flat damage regardless of target defense.",
		"quote": "Might finally graduate from mage school this year if he spends more time studying and less time playing video games.",
		"unitType": "mage",
		"texture": Vector2(0, 3),
		"cost": {
			"Food": 8,
			"Gems": 6
		},
		
		"maxHP": 5,
		"actionSpeed": 0.2,
		"attack": 3,
		"defense": 3,
		
		"maxRange": 2,
		"spell": "Piercing_Bolt"
	},
	"Red Mage": {
		"frequency": 1,
		"description": "Extremely powerful offensive Mage with devastating AOE fireball attack.",
		"quote": "I didn't ask how big the room was. I SAID, 'I cast Fireball.'",
		"unitType": "mage",
		"texture": Vector2(1, 3),
		"cost": {
			"Food": 14,
			"Gems": 18
		},
		
		"maxHP": 10,
		"actionSpeed": 0.3,
		"attack": 5,
		"defense": 6,
		
		"maxRange": 3,
		"spell": "Fireball"
	},
	"Woodland Sage": {
		"frequency": 2,
		"description": "Powerful utility Mage that heals all units in a 2-tile radius.",
		"Woodland Sage": "Pesky pacifist that heals with equal opportunity.",
		"unitType": "mage",
		"texture": Vector2(2, 3),
		"cost": {
			"Food": 16,
			"Gems": 14
		},
		
		"maxHP": 12,
		"actionSpeed": 0.15,
		"attack": 0,
		"defense": 8,
		
		"maxRange": 1,
		"spell": "Healing_Aura"
	},
	
	"Keep": {
		"frequency": 0,
		"description": "Defend your Keep and destroy the enemy's to win! Also periodically generates all Resources.",
		"quote": "Whoever said to keep your friends close but your enemies closer clearly wasn't dealing with a protracted seige.",
		"unitType": "structure",
		"texture": Vector2(0, 0),
		
		"maxHP": 30,
		"actionSpeed": 0.2,
		"attack": 0,
		"defense": 3
	},
	"Wall": {
		"frequency": 6,
		"description": "A wall that blocks projectiles. Can withstand quite a bit of damage before falling down!",
		"quote": "Wall quote.",
		"unitType": "structure",
		"texture": Vector2(1, 0),
		"cost": {
			"Wood": 16
		},
		
		"maxHP": 20,
		"actionSpeed": 0,
		"attack": 0,
		"defense": 3
	}
}

var tilesBase = {
	# Base
	"Grass": {
		"details": "Flat terrain with no effects"
	},
	
	"Water": {
		"details": "Impassable by Units, but projectiles can carry over"
	},
	
	# Bonus
	"Farm": {
		"details": "Generates Food if a Peasant is placed"
	},
	
	"Forest": {
		"details": "Generates Wood if a Peasant is placed; also provides +1 to defense"
	},
	
	"Gems Deposit": {
		"details": "Generates Gems if a Peasant is placed"
	},
	
	"Hill": {
		"details": "Provides a +1 bonus to projectile attack"
	},
	
	"Iron Deposit": {
		"details": "Generates Iron if a Peasant is placed"
	},
	
	"Mountain": {
		"details": "Provides a +2 bonus to defense"
	}
}


var deck = []


func _ready():
	for c in cards:
		var freq = cards[c]["frequency"]
		for i in range(freq):
			deck.append(c)
	print(deck)


func DrawCard():
	var result = deck[randi() % len(deck)]
	deck.erase(result)
	print("Remaining Deck Size: ", len(deck))

	return result
