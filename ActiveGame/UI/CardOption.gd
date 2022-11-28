extends Control


onready var ui = get_parent().get_parent().get_parent().get_parent()
onready var ag = ui.get_parent()


func _ready():
	pass

func _process(delta):
	$Button.self_modulate = Color("ffffff")
	
	var costs = Database.cards[ag.activeCards[int(name[-1])]]["cost"]
	for r in costs:
		if costs[r] > ag.playerResources[r]:
			$Button.self_modulate = Color("afafaf")
	
	if ag.phase == "PLACE_CARD" or not ag.get_node("UI/BuyCard/Timer").is_stopped():
		if int(name[-1]) == ui.playerSelectionIx:
			$Button.self_modulate = Color("6496ff")
		elif int(name[-1]) == ui.opponentSelectionIx:
			$Button.self_modulate = Color("ff9696")
