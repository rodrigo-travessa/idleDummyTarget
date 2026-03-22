extends Label

var tween : Tween

func _ready():
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", get_parent().global_position + Vector2(0, -250), Tween.TRANS_BOUNCE)