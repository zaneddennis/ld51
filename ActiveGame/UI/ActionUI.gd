extends Control

# THIS IS OLD, ONLY HERE FOR POSTERITY


onready var ag = get_parent().get_parent()


func _ready():
	pass


func _process(delta):
	if visible:
		$TimerBar.value = ag.get_node("Timer").time_left
		$TimerBar/Label.text = "%.2f" % stepify(ag.get_node("Timer").time_left, 0.01)
		
		for r in $ResourcesPanel/VBoxContainer.get_children():
			r.get_node("Label").text = str(ag.playerResources[r.name])
