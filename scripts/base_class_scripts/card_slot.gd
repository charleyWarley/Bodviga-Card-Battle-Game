extends Node2D
class_name CardSlot

@warning_ignore("unused_signal")
signal cardslot_filled


@export var slot_type : String
@export var is_opponent_cardslot := false
@export var image : CompressedTexture2D
@export var health_label : RichTextLabel

var is_slot_full := false

@onready var sprite := $Sprite2D


func _on_damage_taken(health_remaing: int, is_attacker: bool) -> void:
	health_label.visible = true
	health_label.parse_bbcode("[center]" + str(health_remaing) + "[center]")
	var health_label_default_position := health_label.position
	if !is_attacker:
		var tween := get_tree().create_tween()
		tween.parallel()
		tween.tween_property(
			health_label, 
			"position", 
			Vector2(health_label.position.x, health_label.position.y - 10), 
			1.0)
		tween.tween_property(
			health_label, "
			modulate", 
			Color(1, 1, 1, 0), 
			1.0)
		await tween.finished
	else:
		await get_tree().create_timer(1.0).timeout
	health_label.visible = false
	health_label.position = health_label_default_position


func _on_card_destroyed(card: Card) -> void:
	card.disconnect("damage_taken", Callable(self, "_on_damage_taken"))
	card.disconnect("card_destroyed", Callable(self, "_on_card_destroyed"))
	health_label.visible = true
	health_label.parse_bbcode("[center]0[center]")
	await get_tree().create_timer(1.0).timeout
	health_label.visible = false
	is_slot_full = false
	print("slot emptied")

func _ready() -> void:
	sprite.texture = image
