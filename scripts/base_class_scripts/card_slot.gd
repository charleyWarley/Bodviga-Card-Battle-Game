extends Node2D
class_name CardSlot

signal cardslot_filled


@export_enum("FIGHTER", "MAGIC", "ITEM") var SlotType : int
@export var is_opponent_cardslot := false
@export var image : CompressedTexture2D

var is_slot_full := false

@onready var sprite := $Sprite2D


func _on_card_destroyed(card: Card) -> void:
	card.disconnect("damage_taken", Callable(self, "_on_damage_taken"))
	card.disconnect("card_destroyed", Callable(self, "_on_card_destroyed"))
	await get_tree().create_timer(1.0).timeout
	is_slot_full = false
	print("slot emptied")


func _ready() -> void:
	sprite.texture = image
