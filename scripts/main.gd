extends Control

var is_fullscreen := false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		is_fullscreen = !is_fullscreen
		set_fullscreen()


func set_fullscreen():
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
