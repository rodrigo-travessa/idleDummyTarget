class_name Dummy extends Node2D

var damage_text_scene: Resource = preload("uid://dcd3vnwjq85qo")

@export var stats: DummyStats = DummyStats.new()
var crit_label_settings: LabelSettings = LabelSettings.new()
var normal_label_settings: LabelSettings = LabelSettings.new()

func _ready():
	crit_label_settings.font_color = Color(1, 0, 0, 1)
	crit_label_settings.font_size = 20
	normal_label_settings.font_color = Color(1, 1, 1, 1)

func _emit_damage_text(value: float, is_crit: bool) -> void:
	var damage_text_float = damage_text_scene.instantiate()
	if is_crit:
		damage_text_float.label_settings = crit_label_settings
	else:
		damage_text_float.label_settings = normal_label_settings
	damage_text_float.text = str(value)
	add_child(damage_text_float)
