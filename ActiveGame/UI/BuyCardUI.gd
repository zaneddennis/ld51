extends Control

# THIS IS OLD, ONLY HERE FOR POSTERITY


onready var ag = get_parent().get_parent()


var playerSelection = 0
var opponentSelection = 0


func _ready():
	pass
	#for i in range(1, 4):
	#	get_node("CardsPanel/VBoxContainer/CardOption%d/Button" % [i]).connect("pressed", self, "_on_CardOption_pressed", [i])

func _process(delta):
	
	var mPos = get_viewport().get_mouse_position()
	if mPos.x < 256:
		var hoveredCard = int(mPos.y / (get_viewport_rect().size.y / 3)) + 1
		
		# todo: fill in details
		$CardDetails/Label.text = Database.cards[ag.activeCards[hoveredCard]]["description"]
		$CardDetails.show()
	
	else:
		$CardDetails.hide()
	
	for r in $ResourcesPanel/VBoxContainer.get_children():
		r.get_node("Label").text = str(ag.playerResources[r.name])


func SelectPlayerCard(c):
	playerSelection = c
	
	var co = get_node("CardsPanel/VBoxContainer/CardOption%d" % [c])
	co.modulate = Color("6496ff")
	
	ag.activeCards[c] = Database.DrawCard()
	
	for i in range(1, 4):
		get_node("CardsPanel/VBoxContainer/CardOption%d/Button" % [i]).disabled = true

func SelectOpponentCard(c):
	opponentSelection = c
	
	var co = get_node("CardsPanel/VBoxContainer/CardOption%d" % [c])
	co.modulate = Color("ff9696")
	
	ag.activeCards[c] = Database.DrawCard()
	
	$Timer.start()


func _on_CardOption_pressed(c):
	SelectPlayerCard(c)
	
	while c == playerSelection:
		c = 1 + randi() % 3
	SelectOpponentCard(c)


func _on_Timer_timeout():
	ag.EnterPlaceCard()
