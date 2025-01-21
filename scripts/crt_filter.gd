extends ColorRect
class_name CRT

enum Ghosts {WINDOWED, FULLSCREEN}
const FULLSCREEN_GHOST := 2.5
const WINDOWED_GHOST := 1.9
var ghost := FULLSCREEN_GHOST

func _ready() -> void:
	Global.crt = self
	get_material().set_shader_parameter("crt_ghost", ghost)


func shake(intensity: float) ->void:
	get_material().set_shader_parameter("crt_ghost", max(10.0, (10.0 * intensity) + ghost))
	await get_tree().create_timer(0.1).timeout
	get_material().set_shader_parameter("crt_ghost", ghost)


func set_ghost(new_ghost: Ghosts) -> void:
	match new_ghost:
		Ghosts.WINDOWED:
			ghost = WINDOWED_GHOST
		Ghosts.FULLSCREEN:
			ghost = FULLSCREEN_GHOST
	get_material().set_shader_parameter("crt_ghost", ghost)
	
