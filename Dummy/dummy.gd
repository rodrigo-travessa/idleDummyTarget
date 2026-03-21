class_name Dummy extends Node2D

var damage_text_scene: Resource = preload("uid://dcd3vnwjq85qo")
var _temp_cd: float = 0.5




func _ready():
	return

func _process(delta: float) -> void:
	_emit_damage_text(delta)


func _emit_damage_text(delta: float):
	if _temp_cd < 0:
		var damage_text_float = damage_text_scene.instantiate()
		damage_text_float.position = get_global_position()
		damage_text_float.text = "999"
		add_child(damage_text_float)
		_temp_cd = 0.5
	_temp_cd -= delta
