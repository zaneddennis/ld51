extends Control


func _ready():
	pass


func _on_MainMenu_pressed():
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")

func _on_Desktop_pressed():
	get_tree().quit()
