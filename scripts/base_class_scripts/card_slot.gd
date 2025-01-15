extends Node2D
class_name CardSlot

@warning_ignore("unused_signal")
signal cardslot_filled

@export var slot_type : String
@export var is_enemy_cardslot := false
@export var image : CompressedTexture2D

var is_slot_full := false

@onready var sprite := $Sprite2D

func _ready() -> void:
	sprite.texture = image
