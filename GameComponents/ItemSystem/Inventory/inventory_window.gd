extends Control

@export var inventory_data: InventoryData
@export var equipment_data: EquipmentData


var current_dragged_item_data: Dictionary

func _process(delta: float) -> void:
	if not has_node("ItemDrag"):
		return
	get_node("ItemDrag").position = get_global_mouse_position() - get_node("ItemDrag").size / 2


func _ready() -> void:
	var save = SaveManager.load_save()
	if save:
		if save.inventory_data:
			inventory_data = save.inventory_data

		if save.equipment_data:
			equipment_data = save.equipment_data

		if equipment_data.item_data.size() == 0:
			equipment_data = EquipmentData.new()
			equipment_data.item_data.resize(9)
	update_inventory_data()
	connect_signals()

func connect_signals() -> void:
	GlobalSignalBus.connect("UpdateInventory", update_inventory_data)

func update_inventory_data() -> void:
	for slot in %SlotGroup.get_children():
		slot.queue_free()

	for slot in %SlotGroup2.get_children():
		slot.queue_free()

	var inventory_index: int = 0
	var equipment_index: int = 0

	if inventory_data and inventory_data.item_data:
		for item_data in inventory_data.item_data:
			var new_slot = preload("uid://lfclvjuoc48l").instantiate() #ItemSlot UUID
			new_slot.current_item = item_data
			new_slot.index = inventory_index
			new_slot.inventory_data = inventory_data
			inventory_index += 1
			%SlotGroup.add_child(new_slot)

	if equipment_data and equipment_data.item_data:
		for item_data in equipment_data.item_data:
			var new_slot = preload("uid://lfclvjuoc48l").instantiate() #ItemSlot UUID
			new_slot.current_item = item_data
			new_slot.index = equipment_index
			new_slot.inventory_data = equipment_data
			equipment_index += 1
			%SlotGroup2.add_child(new_slot)

	SaveManager.save_game(inventory_data, equipment_data)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		var hovered_node : Control = get_viewport().gui_get_hovered_control()
		if hovered_node is not ItemSlot:
			return
		if hovered_node is ItemSlot:
			var source_data = hovered_node.inventory_data
			var current_index : int = hovered_node.index
			if not source_data.item_data[current_index]:
				return
			create_drag_item(current_index, source_data)
			source_data.item_data[current_index] = null
			GlobalSignalBus.UpdateInventory.emit()

	if event.is_action_released("mouse_left"):
		if !current_dragged_item_data:
			return

		var hovered_node: Control = get_viewport().gui_get_hovered_control()
		var item = current_dragged_item_data.get("Item")
		var index = current_dragged_item_data.get("Index")
		var source_data = current_dragged_item_data.get("SourceData")

		if has_node("ItemDrag"):
			delete_dragged_item()

		if not hovered_node is ItemSlot:
			source_data.item_data[index] = item
			GlobalSignalBus.UpdateInventory.emit()
			current_dragged_item_data = {}
			return

		var target_data = hovered_node.inventory_data
		var target_index = hovered_node.index

		if target_data.item_data[target_index]:
			source_data.item_data[index] = item
			GlobalSignalBus.UpdateInventory.emit()
			current_dragged_item_data = {}
			return

		target_data.item_data[target_index] = item
		GlobalSignalBus.UpdateInventory.emit()
		current_dragged_item_data = {}


func delete_dragged_item():
	get_node("ItemDrag").queue_free()

func create_drag_item(Index: int, SourceData: Resource):
	current_dragged_item_data = {"Item" : SourceData.item_data[Index], "Index": Index, "SourceData": SourceData}
	var new_drag_item : TextureRect = TextureRect.new()
	new_drag_item.texture = SourceData.item_data[Index].item_texture
	new_drag_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	new_drag_item.name = "ItemDrag"
	add_child(new_drag_item)
