extends CanvasLayer


func _ready():
	$AudioStreamPlayer.play()


func _on_StartGame_pressed():
	get_tree().change_scene("res://ActiveGame/ActiveGame.tscn")


func _on_ExitToDesktop_pressed():
	get_tree().quit()
