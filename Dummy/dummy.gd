class_name Dummy extends Node2D

var damage_text_scene: Resource = preload("uid://dcd3vnwjq85qo")

@export var stats: DummyStats = DummyStats.new()
@export var max_hp: float = 100.0

@onready var hp_bar: ProgressBar = $HpBar
var crit_label_settings: LabelSettings = LabelSettings.new()
var normal_label_settings: LabelSettings = LabelSettings.new()

func _ready():
	crit_label_settings.font_color = Color(1, 0, 0, 1)
	crit_label_settings.font_size = 20
	normal_label_settings.font_color = Color(1, 1, 1, 1)
	
	if stats:
		stats.max_hp = max_hp
		stats.reset()
	
	_update_hp_bar()

func _update_hp_bar() -> void:
	if hp_bar and stats:
		hp_bar.value = (stats.current_hp / stats.max_hp) * 100.0

func take_damage(value: float, is_crit: bool) -> void:
	_emit_damage_text(value, is_crit)
	stats.current_hp -= value
	_update_hp_bar()
	if stats.current_hp <= 0:
		_die()

func _die() -> void:
	# Award gold based on max HP (just an example formula)
	var reward = stats.max_hp * 0.5
	GlobalSignalBus.EnemyKilled.emit(reward)
	stats.reset()
	_update_hp_bar()
	# Optional: add death animation or effect here

func _emit_damage_text(value: float, is_crit: bool) -> void:
	var damage_text_float = damage_text_scene.instantiate()
	damage_text_float.global_position = global_position
	if is_crit:
		damage_text_float.label_settings = crit_label_settings
	else:
		damage_text_float.label_settings = normal_label_settings
	damage_text_float.text = str(value)
	add_child(damage_text_float)
