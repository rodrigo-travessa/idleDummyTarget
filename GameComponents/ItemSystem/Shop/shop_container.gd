extends Control

@export var inventory_data: InventoryData

var current_dragged_item_data: Dictionary

var item_textures = [
	preload("res://GameComponents/ItemSystem/Items/Armor.png"),
	preload("res://GameComponents/ItemSystem/Items/Helmet.png")
]

func _process(_delta: float) -> void:
	if not has_node("ItemDrag"):
		return
	get_node("ItemDrag").global_position = get_global_mouse_position() - get_node("ItemDrag").size / 2


func _ready() -> void:
	generate_shop_items()
	update_shop_ui()
	connect_signals()

func connect_signals() -> void:
	GlobalSignalBus.connect("UpdateInventory", update_shop_ui)

func generate_shop_items() -> void:
	inventory_data = InventoryData.new()
	inventory_data.item_data.resize(25)
	
	for i in range(25):
		inventory_data.item_data[i] = generate_random_item()

func generate_random_item() -> ItemData:
	var item = ItemData.new()
	item.item_name = "Random Item"
	item.item_texture = item_textures[randi() % item_textures.size()]
	item.item_type = Enums.ItemType.values()[randi() % Enums.ItemType.size()]
	
	var num_stats = randi_range(1, 4)
	var available_stats = Enums.StatId.values()
	available_stats.shuffle()
	
	for i in range(num_stats):
		var stat_id = available_stats[i]
		var stat_value = randi_range(0, 10)
		item.item_stats[stat_id] = stat_value
		
	return item

func update_shop_ui() -> void:
	for slot in %ShopSlotGroup.get_children():
		slot.queue_free()

	var inventory_index: int = 0

	if inventory_data and inventory_data.item_data:
		for item_data in inventory_data.item_data:
			var new_slot = preload("uid://lfclvjuoc48l").instantiate() #ItemSlot UUID
			new_slot.current_item = item_data
			new_slot.index = inventory_index
			new_slot.inventory_data = inventory_data
			inventory_index += 1
			%ShopSlotGroup.add_child(new_slot)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		var hovered_node : Control = get_viewport().gui_get_hovered_control()
		if hovered_node is not ItemSlot:
			return
		
		# Check if the slot belongs to THIS shop container
		if hovered_node.get_parent() != %ShopSlotGroup:
			return

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
	var item = SourceData.item_data[Index]
	current_dragged_item_data = {"Item" : item, "Index": Index, "SourceData": SourceData}
	var new_drag_item : TextureRect = TextureRect.new()
	new_drag_item.texture = item.item_texture
	new_drag_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	new_drag_item.name = "ItemDrag"
	new_drag_item.modulate = get_tier_color(item.item_stats.size())
	
	add_child(new_drag_item)

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
