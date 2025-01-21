extends SFX

@onready var CardSounds := preload("res://scripts/card_sounds.gd")

func _on_card_flipped() -> void:
	play_sound(sound3)


func _on_picked_up() -> void:
	play_sound(sound1)


func _on_returned_to_hand() -> void:
	play_sound(sound2)


func _on_damage_taken(_damage, is_attacker) -> void:
	if is_attacker: return
	randomize()
	sound4 = load(CardSounds.PAIN_SOUNDS[randi_range(1, CardSounds.PAIN_SOUNDS.size())])
	play_sound(sound4)


func _on_attack_completed() -> void:
	randomize()
	sound5 = load(CardSounds.ATTACK_SOUNDS[randi_range(1, CardSounds.ATTACK_SOUNDS.size())])
	play_sound(sound5)


func _on_card_destroyed(_card) -> void:
	randomize()
	sound4 = load(CardSounds.PAIN_SOUNDS[randi_range(1, CardSounds.PAIN_SOUNDS.size())])
	play_sound(sound4)
	


func connect_signals() -> void:
	if target is PlayerCard:
		target.connect("picked_up", Callable(self, "_on_picked_up"))
		target.connect("returned_to_hand", Callable(self, "_on_returned_to_hand"))
	target.connect("card_flipped", Callable(self, "_on_card_flipped"))
	target.connect("damage_taken", Callable(self, "_on_damage_taken"))
	target.connect("card_destroyed", Callable(self, "_on_card_destroyed"))
