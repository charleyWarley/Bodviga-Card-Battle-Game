extends Node2D
class_name Card

signal card_placed
signal card_examined
signal hand_position_updated
signal returned_to_hand
signal card_flipped
signal card_destroyed(card: Card)
signal damage_blocked
signal damage_taken(health_remaining: int, is_attacker: bool)

enum CardSize {SMALL, LARGE}
enum CardType {FIGHTER, MAGIC, ITEM}

@export var card_image : TextureRect
@export var inside_image : TextureRect
@export var damage_indicator: Control
@export var health_label : RichTextLabel
@export var attack_label : RichTextLabel
@export var defense_label : RichTextLabel
@export var stats_labels : Control
@export var shadow : TextureRect


const FLIP_Y := 82.41
const DEFAULT_DURATION := 0.1
const SMALL_STATS_POSITION := Vector2.ZERO
const LARGE_STATS_POSITION := Vector2(9, -7)

var is_flipping := false
var is_in_field := false
var inside_large : CompressedTexture2D
var inside_small : CompressedTexture2D
var card_type : int
var card_size : int
var current_cardslot : CardSlot = null
var parent : CardManager
var hand_position : Vector2
var power : int
var defense : int
var health : int
var starting_position : Vector2
var return_position_x : float

@onready var card_small := preload("res://images/card_images/empty_small.png")
@onready var card_large := preload("res://images/card_images/empty_large.png")
@onready var card_back := preload("res://images/card_images/card_back.png")


func _on_card_examined() -> void:
	print(name, " power: ", power, " defense: ", defense)


##called when Hand updates card positions and emits signal
func _on_hand_position_updated(new_position: Vector2, duration:=DEFAULT_DURATION) -> void:
	hand_position = new_position
	return_position_x = new_position.x
	animate_card_to_position(new_position, duration)

func _on_card_flipped() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(card_image.material, "shader_parameter/yDegrees", FLIP_Y, 0.1)
	await get_tree().create_timer(0.15).timeout
	flip_card()
	var tween2 := get_tree().create_tween()
	tween2.tween_property(card_image.material, "shader_parameter/yDegrees", 0.0, 0.1)
	


func animate_card_to_position(new_position: Vector2, duration:float=DEFAULT_DURATION) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(
		self, 
		"position", new_position,
		duration)


func set_card_image(outside: CompressedTexture2D, inside: CompressedTexture2D) -> void:
	card_image.set_texture(outside)
	inside_image.set_texture(inside)
	if inside == inside_small:
		health_label.visible = true
		stats_labels.position = SMALL_STATS_POSITION 
		
	else:
		health_label.visible = false
		stats_labels.position = LARGE_STATS_POSITION
	

func take_damage(damage: int, is_attacker: bool):
	print(name, " ", damage, " ", is_attacker)
	if damage <= 0: 
		damage_blocked.emit()
		print("damage blocked")
		return
	
	damage_indicator.visible = true
	health -= damage
	damage_taken.emit(health, is_attacker)
	health_label.parse_bbcode("[center]" + str(clamp(health, 0, 10)) + "[/center]")
	await get_tree().create_timer(0.5).timeout
	
	if health <= 0:
		card_destroyed.emit(self)
		await get_tree().create_timer(1.0).timeout
	damage_indicator.visible = false
	

func flip_card() -> void:
	pass

func connect_signals() -> void:
	pass
 
