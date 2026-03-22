class_name DummyStats extends Resource

@export_group("Core Attributes")
@export var max_hp: float = 100.0
@export var defense: float = 5.0
@export var magic_defense: float = 5.0
@export var hp_regen: float = 0.0
@export var evasion: float = 0.0


func get_stat(stat_id: Enums.DummyStats ) -> float:
	match stat_id:
		Enums.DummyStats.MAX_HP: return max_hp
		Enums.DummyStats.DEFENSE: return defense
		Enums.DummyStats.MAGIC_DEFENSE: return magic_defense
		Enums.DummyStats.HP_REGEN: return hp_regen
		Enums.DummyStats.EVASION: return evasion
		_: return 0.0

func set_stat(stat_id: Enums.DummyStats, value: float) -> void:
	match stat_id:
		Enums.DummyStats.MAX_HP: max_hp = value
		Enums.DummyStats.DEFENSE: defense = value
		Enums.DummyStats.MAGIC_DEFENSE: magic_defense = value
		Enums.DummyStats.HP_REGEN: hp_regen = value
		Enums.DummyStats.EVASION: evasion = value

