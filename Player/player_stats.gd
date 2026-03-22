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


func get_stat(stat_id: Enums.StatId) -> float:
	match stat_id:
		Enums.StatId.MAX_HP: return max_hp
		Enums.StatId.MAX_MANA: return max_mana
		Enums.StatId.STRENGTH: return strength  
		Enums.StatId.DEXTERITY: return dexterity
		Enums.StatId.INTELLIGENCE: return intelligence
		Enums.StatId.VITALITY: return vitality
		Enums.StatId.LUCK: return luck
		Enums.StatId.ATTACK_POWER: return attack_power
		Enums.StatId.MAGIC_POWER: return magic_power
		Enums.StatId.DEFENSE: return defense
		Enums.StatId.MAGIC_DEFENSE: return magic_defense
		Enums.StatId.CRIT_CHANCE: return crit_chance
		Enums.StatId.CRIT_DAMAGE: return crit_damage
		Enums.StatId.ATTACK_SPEED: return attack_speed
		Enums.StatId.CAST_SPEED: return cast_speed
		Enums.StatId.ACCURACY: return accuracy
		Enums.StatId.EVASION: return evasion
		Enums.StatId.MOVE_SPEED: return move_speed
		Enums.StatId.COOLDOWN_REDUCTION: return cooldown_reduction
		Enums.StatId.LIFE_STEAL: return life_steal
		Enums.StatId.STATUS_CHANCE: return status_chance
		Enums.StatId.STATUS_DURATION: return status_duration
		Enums.StatId.ARMOR_PENETRATION: return armor_penetration
		Enums.StatId.MAGIC_PENETRATION: return magic_penetration
		Enums.StatId.MANA_REGEN: return mana_regen
		Enums.StatId.HP_REGEN: return hp_regen
		_: return 0.0


func set_stat(stat_id: Enums.StatId, value: float) -> void:
	match stat_id:
		Enums.StatId.MAX_HP: max_hp = value
		Enums.StatId.MAX_MANA: max_mana = value
		Enums.StatId.STRENGTH: strength = value
		Enums.StatId.DEXTERITY: dexterity = value
		Enums.StatId.INTELLIGENCE: intelligence = value
		Enums.StatId.VITALITY: vitality = value
		Enums.StatId.LUCK: luck = value
		Enums.StatId.ATTACK_POWER: attack_power = value
		Enums.StatId.MAGIC_POWER: magic_power = value
		Enums.StatId.DEFENSE: defense = value
		Enums.StatId.MAGIC_DEFENSE: magic_defense = value
		Enums.StatId.CRIT_CHANCE: crit_chance = value
		Enums.StatId.CRIT_DAMAGE: crit_damage = value
		Enums.StatId.ATTACK_SPEED: attack_speed = value
		Enums.StatId.CAST_SPEED: cast_speed = value
		Enums.StatId.ACCURACY: accuracy = value
		Enums.StatId.EVASION: evasion = value
		Enums.StatId.MOVE_SPEED: move_speed = value
		Enums.StatId.COOLDOWN_REDUCTION: cooldown_reduction = value
		Enums.StatId.LIFE_STEAL: life_steal = value
		Enums.StatId.STATUS_CHANCE: status_chance = value
		Enums.StatId.STATUS_DURATION: status_duration = value
		Enums.StatId.ARMOR_PENETRATION: armor_penetration = value
		Enums.StatId.MAGIC_PENETRATION: magic_penetration = value
		Enums.StatId.MANA_REGEN: mana_regen = value
		Enums.StatId.HP_REGEN: hp_regen = value


