extends TextureRect
class_name ItemSlot

@export var current_item: ItemData
var index: int
var inventory_data: Resource
var tooltip_scene : PackedScene = preload("res://GameComponents/UI_Components/tooltip.tscn") #ItemTooltipScene
var tooltip

func _ready() -> void:
	set_item_slot()
	tooltip = tooltip_scene.instantiate()


func set_item_slot() -> void:
	if not current_item:
		return
	%ItemTexture.texture = current_item.item_texture
	%ItemAmountLabel.text = str(current_item.item_amount)
	%ItemTexture.modulate = get_tier_color(current_item.item_stats.size())

func get_tier_color(modifier_count: int) -> Color:
	match modifier_count:
		2:
			return Color.GREEN
		3:
			return Color.CORNFLOWER_BLUE
		4:
			return Color.MEDIUM_PURPLE
		_:
			return Color.WHITE

func _on_mouse_entered():
	if current_item:
		tooltip = tooltip_scene.instantiate()
		tooltip.visible = true
		tooltip.ItemName = current_item.item_name
		tooltip.ItemTexture = current_item.item_texture
		tooltip.ItemPrice = current_item.price
		tooltip.TextureModulate = get_tier_color(current_item.item_stats.size())

		var stats_text = ""
		for stat_id in current_item.item_stats:
			var stat_name = Enums.StatId.keys()[stat_id].capitalize()
			var stat_value = current_item.item_stats[stat_id]
			stats_text += "%s: %s\n" % [stat_name, stat_value]

		tooltip.ItemStats = stats_text
		tooltip.global_position = get_global_mouse_position() + Vector2(5, 5)
		get_tree().root.add_child.call_deferred(tooltip)




func _on_mouse_exited() -> void:
	tooltip.visible = false
