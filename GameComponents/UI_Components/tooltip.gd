class_name ItemTooltip
extends Control

var ItemName: String
var ItemStats: String
var ItemTexture: Texture2D
var TextureModulate: Color = Color.WHITE

func _ready() -> void:
	%ItemName.text = ItemName
	%ItemTexture.texture = ItemTexture
	%ItemTexture.modulate = TextureModulate
	%ItemStats.text = ItemStats
	get_tree().create_timer(10).timeout.connect(queue_free)
