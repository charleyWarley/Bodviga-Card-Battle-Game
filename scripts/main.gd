extends Control

var is_fullscreen := true


func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(640*2, 360*2))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		set_fullscreen()


func set_fullscreen():
	is_fullscreen = !is_fullscreen
	if is_fullscreen:
		Global.crt.set_ghost(Global.crt.Ghosts.FULLSCREEN)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Global.crt.set_ghost(Global.crt.Ghosts.WINDOWED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(640*2, 360*2))
		
