class_name ItemTooltip
extends Control

var ItemName: String
var ItemStats: String
var ItemPrice: int
var ItemTexture: Texture2D
var TextureModulate: Color = Color.WHITE

func _ready() -> void:
	%ItemName.text = ItemName
	%ItemTexture.texture = ItemTexture
	%ItemTexture.modulate = TextureModulate
	%ItemStats.text = ItemStats + "Price: %s Gold" % ItemPrice
	
	# Adjust position to stay within viewport
	call_deferred("_adjust_position")

func _adjust_position() -> void:
	var viewport_rect = get_viewport_rect()
	var tooltip_size = $TextureRect.size # Using the background texture size
	
	var target_pos = global_position
	
	# Check right edge
	if target_pos.x + tooltip_size.x > viewport_rect.size.x:
		target_pos.x -= tooltip_size.x + 10 # 10 is a small offset
		
	# Check bottom edge
	if target_pos.y + tooltip_size.y > viewport_rect.size.y:
		target_pos.y -= tooltip_size.y + 10
		
	global_position = target_pos
