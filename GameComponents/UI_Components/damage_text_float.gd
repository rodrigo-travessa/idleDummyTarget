extends Label

var tween : Tween

func _ready():
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -250), 1.0).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(queue_free)