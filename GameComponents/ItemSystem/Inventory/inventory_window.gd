extends Control

@export var inventory_data: InventoryData
var current_dragged_item_data: Dictionary

func _process(delta: float) -> void:
	if not has_node("ItemDrag"):
		return
	get_node("ItemDrag").position = get_global_mouse_position() - get_node("ItemDrag").size / 2
	

func _ready() -> void:
	update_inventory_data()
	connect_signals()

func connect_signals() -> void:
	GlobalSignalBus.connect("UpdateInventory", update_inventory_data)

func update_inventory_data() -> void:
	for slot in %SlotGroup.get_children():
		slot.queue_free()

	var inventory_index: int = 0

	for item_data in inventory_data.item_data:
		var new_slot = preload("uid://lfclvjuoc48l").instantiate() #ItemSlot UUID
		new_slot.current_item = item_data
		new_slot.index = inventory_index
		inventory_index += 1
		%SlotGroup.add_child(new_slot)
