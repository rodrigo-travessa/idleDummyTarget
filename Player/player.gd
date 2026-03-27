class_name Player extends Node2D

@export var stats: PlayerStats
@export var equipment_data: EquipmentData
@export var target: Dummy

var delay_between_attacks: float = 1.0
var time_until_next_attack: float = 0.0

func _ready():
	var save = SaveManager.load_save()
	if save and save.equipment_data:
		equipment_data = save.equipment_data
	
	GlobalSignalBus.connect("UpdateInventory", _on_inventory_updated)
	update_effective_stats()
	delay_between_attacks = stats.get_stat(Enums.StatId.ATTACK_SPEED) / 1

func _on_inventory_updated() -> void:
	# Small delay to ensure the save is completed if triggered by the same signal
	await get_tree().process_frame
	
	# Reload equipment data to reflect changes in the save file
	var save = SaveManager.load_save()
	if save and save.equipment_data:
		equipment_data = save.equipment_data
	
	update_effective_stats()

func update_effective_stats() -> void:
	stats.reset_bonuses()
	if equipment_data:
		for item in equipment_data.item_data:
			if item and item.item_stats:
				for stat_id in item.item_stats:
					stats.add_bonus(stat_id, item.item_stats[stat_id])
	
	# Update internal variables that depend on stats
	delay_between_attacks = stats.get_stat(Enums.StatId.ATTACK_SPEED) / 1

func _process(delta: float) -> void:
	if target and time_until_next_attack <= 0:
		var attack_result = calculate_damage()
		target._emit_damage_text(attack_result[0], attack_result[1])
		time_until_next_attack = delay_between_attacks
	time_until_next_attack -= delta


func calculate_damage() -> Array:
	var final_damage = stats.get_stat(Enums.StatId.ATTACK_POWER) \
	+ stats.get_stat(Enums.StatId.STRENGTH) * 5 \
	+ stats.get_stat(Enums.StatId.DEXTERITY) * 1

	# Handle Critical Hits
	var is_crit = randf_range(0.0, 100.0) <= stats.get_stat(Enums.StatId.CRIT_CHANCE)
	if is_crit:
		final_damage *= (1.0 + stats.get_stat(Enums.StatId.CRIT_DAMAGE) / 100.0)

	return [final_damage, is_crit]
