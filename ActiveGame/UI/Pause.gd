extends Control


func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if visible:
			Close()
		else:
			Activate()

func Activate():
	get_tree().paused = true
	show()

func Close():
	get_tree().paused = false
	hide()


func _on_Resume_pressed():
	Close()

func _on_MainMenu_pressed():
	Close()
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")

func _on_Quit_pressed():
	get_tree().quit()
