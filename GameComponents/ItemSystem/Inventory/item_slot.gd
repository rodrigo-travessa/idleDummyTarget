extends TextureRect
class_name ItemSlot

@export var current_item: ItemData
var index: int

func _ready() -> void:
	set_item_slot()

func _get_drag_data(point: Vector2) -> Variant:
	if not current_item:
		return
	var preview : ItemSlot = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(12, 12)

	set_drag_preview(c)
	return current_item

func _can_drop_data(point: Vector2, data: Variant) -> bool:
	return true

func _drop_data(point: Vector2, data: Variant) -> void:
	print("Dropped item: " + str(data))
	print(str(point.x) + ", " + str(point.y))
	print(str(index))
	current_item = data
	set_item_slot()
	data = null


func set_item_slot() -> void:
	if not current_item:
		return
	%ItemTexture.texture = current_item.item_texture
	%ItemAmountLabel.text = str(current_item.item_amount)
