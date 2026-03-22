class_name Player extends Node2D

@export var stats: PlayerStats
@export var target: Dummy

var delay_between_attacks: float = 1.0
var time_until_next_attack: float = 0.0

func _ready():
	delay_between_attacks = stats.get_stat(Enums.StatId.ATTACK_SPEED) / 1

func _process(delta: float) -> void:
	if target and time_until_next_attack <= 0:
		var attack_result = calculate_damage()
		target._emit_damage_text(attack_result[0], attack_result[1])
		time_until_next_attack = stats.get_stat(Enums.StatId.ATTACK_SPEED) / 1
	time_until_next_attack -= delta


func calculate_damage() -> Array:
	var final_damage = stats.get_stat(Enums.StatId.ATTACK_POWER) \
	+ stats.get_stat(Enums.StatId.STRENGTH) * 5 \
	+ stats.get_stat(Enums.StatId.DEXTERITY) * 1

	# Handle Critical Hits
	var is_crit = randf_range(0.0, 100.0) <= stats.crit_chance
	if is_crit:
		final_damage *= (1.0 + stats.crit_damage / 100.0)

	return [final_damage, is_crit]
