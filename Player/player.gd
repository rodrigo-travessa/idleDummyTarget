class_name Player extends Node2D

@export var stats: PlayerStats
@export var equipment_data: EquipmentData
@export var target: Dummy

var delay_between_attacks: float = 1.0
var time_until_next_attack: float = 0.0

func _ready():
	var save = SaveManager.load_save()
	if save:
		if save.equipment_data:
			equipment_data = save.equipment_data
		if save.player_stats:
			# If we have saved stats, we should probably use them, 
			# but be careful not to overwrite the reference if it's already set from editor
			# and contains important metadata.
			# For now, let's just copy the gold.
			stats.total_gold = save.player_stats.total_gold
	
	GlobalSignalBus.connect("UpdateInventory", _on_inventory_updated)
	update_effective_stats()

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
	
	# Formula for delay between attacks influenced by Attack Speed and Dexterity
	# Base attack speed of 1.0 (one attack per second)
	# Each point of Dexterity adds 5% attack speed
	# Each point of Attack Speed stat adds 10% attack speed
	var total_attack_speed = stats.get_stat(Enums.StatId.ATTACK_SPEED) * 0.1 \
			+ stats.get_stat(Enums.StatId.DEXTERITY) * 0.05
	delay_between_attacks = 1.0 / (1.0 + total_attack_speed)

func _process(delta: float) -> void:
	if target:
		if time_until_next_attack <= 0:
			var attack_result = calculate_damage()
			var damage_dealt = attack_result[0]
			var is_crit = attack_result[1]
			target._emit_damage_text(damage_dealt, is_crit)
			GlobalSignalBus.PlayerDamaged.emit(damage_dealt)
			time_until_next_attack = delay_between_attacks
		time_until_next_attack -= delta


func calculate_damage() -> Array:
	# Damage influenced by Strength and Attack Power
	# Base damage could be 1.0, Strength adds 5.0 per point, Attack Power adds 1.0 per point
	var final_damage = 1.0 \
	+ stats.get_stat(Enums.StatId.ATTACK_POWER) \
	+ stats.get_stat(Enums.StatId.STRENGTH) * 5.0

	# Luck and crit chance should influence critical chance
	# Luck adds 0.5% crit chance per point, plus the base crit chance stat
	var total_crit_chance = stats.get_stat(Enums.StatId.CRIT_CHANCE) \
			+ stats.get_stat(Enums.StatId.LUCK) * 0.5
	
	# Luck and crit damage should influence critical damage multiplier
	# Luck adds 1% crit damage per point, plus the base crit damage stat
	var total_crit_damage = stats.get_stat(Enums.StatId.CRIT_DAMAGE) \
			+ stats.get_stat(Enums.StatId.LUCK) * 1.0
	
	# Handle Critical Hits
	var is_crit = randf_range(0.0, 100.0) <= total_crit_chance
	if is_crit:
		final_damage *= (1.0 + total_crit_damage / 100.0)

	return [final_damage, is_crit]
