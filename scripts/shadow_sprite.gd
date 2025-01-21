extends TextureRect

@export var is_opponent := false

enum ShadowSize {SMALL, LARGE}

const SCREEN_CENTER := Vector2(638/2, 358/2)
const LARGE_SCALE := Vector2(1.837, 1.837)
const SMALL_SCALE := Vector2(1.075, 1.075)
const DEFAULT_POSITION_Y := -30.0

var card_center := -22
var max_offset := -6
var parent : Card
var is_moving := false


func _on_size_changed(new_size: int) -> void:
	match new_size:
		ShadowSize.SMALL: 
			make_small()
		ShadowSize.LARGE:
			make_large()

#
func _ready() -> void:
	if !is_opponent: 
		scale = LARGE_SCALE
	parent = get_parent()
	connect_signals()
#
#
func _physics_process(delta: float) -> void:
	var center_x := 638 / 2
	var distance := parent.global_position.x - center_x
	var shadow_position : float = -sign(distance) * max_offset
	var speed : float = abs(distance / center_x) * 30
	position.x = lerp(position.x, shadow_position + card_center, speed * delta)


func make_small() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", 
		SMALL_SCALE, 0.1)


func make_large() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", 
		LARGE_SCALE, 0.1)


func connect_signals() -> void:
	if is_opponent: return
	parent.connect("size_changed", Callable(self, "_on_size_changed"))
	parent.connect("picked_up", Callable(self, "_on_picked_up"))
	parent.connect("dropped", Callable(self, "_on_dropped"))
