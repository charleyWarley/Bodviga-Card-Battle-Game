extends SFXComponent

@onready var attack_sounds := {
	1: preload("res://audio/standin_sounds/attack_sounds/attacksound1.mp3"),
	2: preload("res://audio/standin_sounds/attack_sounds/attacksound2.mp3"),
	3: preload("res://audio/standin_sounds/attack_sounds/attacksound3.mp3"),
	4: preload("res://audio/standin_sounds/attack_sounds/attacksound4.mp3"),
	5: preload("res://audio/standin_sounds/attack_sounds/attacksound5.mp3"),
	6: preload("res://audio/standin_sounds/attack_sounds/attacksound6.mp3"),
	7: preload("res://audio/standin_sounds/attack_sounds/attacksound7.mp3"),
	8: preload("res://audio/standin_sounds/attack_sounds/attacksound8.mp3"),
	9: preload("res://audio/standin_sounds/attack_sounds/attacksound9.mp3"),
	10: preload("res://audio/standin_sounds/attack_sounds/attacksound10.mp3")
}
@onready var pain_sounds := {
	1: preload("res://audio/standin_sounds/pain_sounds/painsound1.mp3"),
	2: preload("res://audio/standin_sounds/pain_sounds/painsound2.mp3"),
	3: preload("res://audio/standin_sounds/pain_sounds/painsound3.mp3"),
	4: preload("res://audio/standin_sounds/pain_sounds/painsound5.mp3"),
	5: preload("res://audio/standin_sounds/pain_sounds/painsound6.mp3"),
	6: preload("res://audio/standin_sounds/pain_sounds/painsound6.mp3"),
	7: preload("res://audio/standin_sounds/pain_sounds/painsound7.mp3"),
	8: preload("res://audio/standin_sounds/pain_sounds/painsound8.mp3"),
	9: preload("res://audio/standin_sounds/pain_sounds/painsound9.mp3"),
	10: preload("res://audio/standin_sounds/pain_sounds/painsound10.mp3"),
	11: preload("res://audio/standin_sounds/pain_sounds/painsound11.mp3")
}

func _on_card_flipped() -> void:
	play_sound(sound3)


func _on_picked_up() -> void:
	play_sound(sound1)


func _on_returned_to_hand() -> void:
	play_sound(sound2)


func _on_damage_taken(_damage, is_attacker) -> void:
	if is_attacker: return
	randomize()
	sound4 = pain_sounds[randi_range(1, pain_sounds.size())]
	play_sound(sound4)
	print(sound4)


func _on_attack_completed() -> void:
	randomize()
	sound5 = attack_sounds[randi_range(1, attack_sounds.size())]
	play_sound(sound5)


func _on_card_destroyed(_card) -> void:
	randomize()
	sound4 = pain_sounds[randi_range(1, pain_sounds.size())]
	play_sound(sound4)
	


func connect_signals() -> void:
	target.connect("picked_up", Callable(self, "_on_picked_up"))
	target.connect("returned_to_hand", Callable(self, "_on_returned_to_hand"))
	target.connect("card_flipped", Callable(self, "_on_card_flipped"))
	target.connect("damage_taken", Callable(self, "_on_damage_taken"))
	target.connect("card_destroyed", Callable(self, "_on_card_destroyed"))
