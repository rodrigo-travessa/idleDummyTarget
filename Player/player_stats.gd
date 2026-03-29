class_name PlayerStats extends Resource

@export_group("Core Attributes")
@export var max_hp: float = 100.0
@export var max_mana: float = 50.0
@export var strength: float = 10.0
@export var dexterity: float = 10.0
@export var intelligence: float = 10.0
@export var vitality: float = 10.0
@export var luck: float = 10.0

@export_group("Offense")
@export var attack_power: float = 10.0
@export var magic_power: float = 10.0
@export var crit_chance: float = 5.0
@export var crit_damage: float = 50.0
@export var attack_speed: float = 1.0
@export var cast_speed: float = 1.0
@export var accuracy: float = 100.0
@export var life_steal: float = 0.0
@export var status_chance: float = 0.0
@export var cooldown_reduction: float = 0.0
@export var status_duration: float = 0.0
@export var armor_penetration: float = 0.0
@export var magic_penetration: float = 0.0

@export_group("Defense")
@export var move_speed: float = 300.0
@export var defense: float = 5.0
@export var magic_defense: float = 5.0
@export var evasion: float = 0.0
@export var mana_regen: float = 0.0
@export var hp_regen: float = 0.0


@export var total_gold: float = 0.0:
	set(value):
		total_gold = value
		GoldChanged.emit(total_gold)
		StatsChanged.emit()

var bonus_stats: Dictionary = {}

signal StatsChanged
signal GoldChanged(new_amount: float)

func get_stat(stat_id: Enums.StatId) -> float:
	var base_value: float = 0.0
	match stat_id:
		#Enums.StatId.MAX_HP: base_value = max_hp
		#Enums.StatId.MAX_MANA: base_value = max_mana
		Enums.StatId.STRENGTH: base_value = strength
		Enums.StatId.DEXTERITY: base_value = dexterity
		#Enums.StatId.INTELLIGENCE: base_value = intelligence
		#Enums.StatId.VITALITY: base_value = vitality
		Enums.StatId.LUCK: base_value = luck
		Enums.StatId.ATTACK_POWER: base_value = attack_power
		#Enums.StatId.MAGIC_POWER: base_value = magic_power
		#Enums.StatId.DEFENSE: base_value = defense
		#Enums.StatId.MAGIC_DEFENSE: base_value = magic_defense
		Enums.StatId.CRIT_CHANCE: base_value = crit_chance
		Enums.StatId.CRIT_DAMAGE: base_value = crit_damage
		Enums.StatId.ATTACK_SPEED: base_value = attack_speed
		#Enums.StatId.CAST_SPEED: base_value = cast_speed
		#Enums.StatId.ACCURACY: base_value = accuracy
		#Enums.StatId.EVASION: base_value = evasion
		#Enums.StatId.MOVE_SPEED: base_value = move_speed
		#Enums.StatId.COOLDOWN_REDUCTION: base_value = cooldown_reduction
		#Enums.StatId.LIFE_STEAL: base_value = life_steal
		#Enums.StatId.STATUS_CHANCE: base_value = status_chance
		#Enums.StatId.STATUS_DURATION: base_value = status_duration
		#Enums.StatId.ARMOR_PENETRATION: base_value = armor_penetration
		#Enums.StatId.MAGIC_PENETRATION: base_value = magic_penetration
		#Enums.StatId.MANA_REGEN: base_value = mana_regen
		#Enums.StatId.HP_REGEN: base_value = hp_regen
		_: base_value = 0.0

	return base_value + bonus_stats.get(stat_id, 0.0)

func get_stat_string() -> String:
	var stats_string: String = ""

	stats_string += "Gold: %s \n" % total_gold
	stats_string += "Strength: %s \n" % get_stat(Enums.StatId.STRENGTH)
	stats_string += "Dexterity: %s \n" % get_stat(Enums.StatId.DEXTERITY)
	stats_string += "Luck: %s \n" % get_stat(Enums.StatId.LUCK)
	stats_string += "Attack Power: %s \n" % get_stat(Enums.StatId.ATTACK_POWER)
	stats_string += "Crit Chance: %s \n" % get_stat(Enums.StatId.CRIT_CHANCE)
	stats_string += "Crit Damage: %s \n" % get_stat(Enums.StatId.CRIT_DAMAGE)
	stats_string += "Attack Speed: %s \n" % get_stat(Enums.StatId.ATTACK_SPEED)

	return stats_string

func reset_bonuses() -> void:
	bonus_stats.clear()

func add_bonus(stat_id: Enums.StatId, value: float) -> void:
	bonus_stats[stat_id] = bonus_stats.get(stat_id, 0.0) + value
	StatsChanged.emit()


func set_stat(stat_id: Enums.StatId, value: float) -> void:
	match stat_id:
		#Enums.StatId.MAX_HP: max_hp = value
		#Enums.StatId.MAX_MANA: max_mana = value
		Enums.StatId.STRENGTH: strength = value
		Enums.StatId.DEXTERITY: dexterity = value
		#Enums.StatId.INTELLIGENCE: intelligence = value
		#Enums.StatId.VITALITY: vitality = value
		Enums.StatId.LUCK: luck = value
		Enums.StatId.ATTACK_POWER: attack_power = value
		#Enums.StatId.MAGIC_POWER: magic_power = value
		#Enums.StatId.DEFENSE: defense = value
		#Enums.StatId.MAGIC_DEFENSE: magic_defense = value
		Enums.StatId.CRIT_CHANCE: crit_chance = value
		Enums.StatId.CRIT_DAMAGE: crit_damage = value
		Enums.StatId.ATTACK_SPEED: attack_speed = value

	StatsChanged.emit()
	#	Enums.StatId.CAST_SPEED: cast_speed = value
	#	Enums.StatId.ACCURACY: accuracy = value
	#	Enums.StatId.EVASION: evasion = value
	#	Enums.StatId.MOVE_SPEED: move_speed = value
	#	Enums.StatId.COOLDOWN_REDUCTION: cooldown_reduction = value
	#	Enums.StatId.LIFE_STEAL: life_steal = value
	#	Enums.StatId.STATUS_CHANCE: status_chance = value
	#	Enums.StatId.STATUS_DURATION: status_duration = value
	#	Enums.StatId.ARMOR_PENETRATION: armor_penetration = value
		#Enums.StatId.MAGIC_PENETRATION: magic_penetration = value
	#	Enums.StatId.MANA_REGEN: mana_regen = value
		#Enums.StatId.HP_REGEN: hp_regen = value
