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

func _on_mouse_entered():
	if current_item:
		tooltip = tooltip_scene.instantiate()
		tooltip.visible = true
		tooltip.ItemName = current_item.item_name
		tooltip.ItemTexture = current_item.item_texture
		tooltip.ItemStats = "Placeholder Stats"
		tooltip.global_position = get_global_mouse_position() + Vector2(5, 5)
		get_tree().root.add_child.call_deferred(tooltip)




func _on_mouse_exited() -> void:
	tooltip.visible = false
