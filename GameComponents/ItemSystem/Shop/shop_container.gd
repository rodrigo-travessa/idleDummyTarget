extends Control

@export var inventory_data: InventoryData

var current_dragged_item_data: Dictionary
var shop_size: int = 60

var item_textures = {
	Enums.ItemType.HELMET: preload("res://GameComponents/ItemSystem/Items/Helmet.png"),
	Enums.ItemType.CHEST: preload("res://GameComponents/ItemSystem/Items/Armor.png"),
	Enums.ItemType.PANTS: preload("res://GameComponents/ItemSystem/Items/pants.png"),
	Enums.ItemType.RING: preload("res://GameComponents/ItemSystem/Items/Ring.png"),
	Enums.ItemType.BELT: preload("res://GameComponents/ItemSystem/Items/belt.png"),
	Enums.ItemType.BOOTS: preload("res://GameComponents/ItemSystem/Items/boots.png"),
	Enums.ItemType.AMULET: preload("res://GameComponents/ItemSystem/Items/amulet.png")
}

func _process(_delta: float) -> void:
	if not has_node("ItemDrag"):
		return
	
	var drag_item = get_node("ItemDrag")
	var viewport_rect = get_viewport_rect()
	var target_pos = get_global_mouse_position() - drag_item.size / 2
	
	# Clamp to screen
	target_pos.x = clamp(target_pos.x, 0, viewport_rect.size.x - drag_item.size.x)
	target_pos.y = clamp(target_pos.y, 0, viewport_rect.size.y - drag_item.size.y)
	
	drag_item.global_position = target_pos


func _ready() -> void:
	generate_shop_items()
	update_shop_ui()
	connect_signals()
	%RefreshShopButton.pressed.connect(_on_refresh_shop_button_pressed)

func _on_refresh_shop_button_pressed() -> void:
	generate_shop_items()
	update_shop_ui()

func connect_signals() -> void:
	GlobalSignalBus.connect("UpdateInventory", update_shop_ui)

func generate_shop_items() -> void:
	inventory_data = InventoryData.new()
	inventory_data.item_data.resize(shop_size)
	
	var player: Player = get_tree().root.find_child("Player", true, false)
	var luck = player.stats.get_stat(Enums.StatId.LUCK) if player and player.stats else 0.0
	
	# Base weights: Common 50%, Uncommon 25%, Rare 12.5%, Epic 6.75%, Legendary 0.75%
	# Total 'Rare or better' = 12.5 + 6.75 + 0.75 = 20%
	var weight_common = 50.0
	var weight_uncommon = 25.0
	var weight_rare = 12.5
	var weight_epic = 6.75
	var weight_legendary = 0.75
	
	# Luck influence:
	# To have > 50% 'Rare or better' at 50 Luck, we need to shift weight from Common/Uncommon.
	# Let's shift 1.2% per point of luck from Common/Uncommon pool to Rare+ pool.
	# At 50 Luck, shift = 60%.
	# Common: 50 -> 10, Uncommon: 25 -> 5. Total Common/Uncommon = 15%.
	# Rare+ gets 20 + 60 = 80%. This satisfies > 50%.
	
	var shift_per_luck = 1.2
	var total_shift = luck * shift_per_luck
	
	var base_common_uncommon = weight_common + weight_uncommon
	var actual_shift = min(total_shift, base_common_uncommon - 10.0) # Keep at least 10% for C/U
	
	if actual_shift > 0:
		var shift_common = actual_shift * (weight_common / base_common_uncommon)
		var shift_uncommon = actual_shift * (weight_uncommon / base_common_uncommon)
		
		weight_common -= shift_common
		weight_uncommon -= shift_uncommon
		
		var base_rare_plus = weight_rare + weight_epic + weight_legendary
		weight_rare += actual_shift * (weight_rare / base_rare_plus)
		weight_epic += actual_shift * (weight_epic / base_rare_plus)
		weight_legendary += actual_shift * (weight_legendary / base_rare_plus)

	for i in range(shop_size):
		var roll = randf_range(0, 100.0)
		var num_stats = 1
		
		if roll <= weight_common:
			num_stats = 1
		elif roll <= weight_common + weight_uncommon:
			num_stats = 2
		elif roll <= weight_common + weight_uncommon + weight_rare:
			num_stats = 3
		elif roll <= weight_common + weight_uncommon + weight_rare + weight_epic:
			num_stats = 4
		else:
			num_stats = 6
		
		inventory_data.item_data[i] = generate_random_item_by_stats(num_stats)

func generate_random_item_by_stats(num_stats: int) -> ItemData:
	var is_legendary = (num_stats == 6)
	var item = ItemData.new()
	item.item_name = "Legendary Item" if is_legendary else "Random Item"
	item.item_type = item_textures.keys()[randi() % item_textures.size()]
	item.item_texture = item_textures[item.item_type]
	
	var available_stats = Enums.StatId.values()
	available_stats.shuffle()
	
	for i in range(num_stats):
		var stat_id = available_stats[i]
		var stat_value = randi_range(0, 10)
		item.item_stats[stat_id] = stat_value
	
	match num_stats:
		1: # Normal
			item.price = randi_range(100, 1000)
		2: # Uncommon
			item.price = randi_range(1000, 3000)
		3: # Rare
			item.price = randi_range(3000, 10000)
		4: # Epic
			item.price = randi_range(10000, 25000)
		6: # Legendary
			item.price = randi_range(50000, 100000)
		_:
			item.price = item.item_stats.size() * 10 + randi_range(0, 10)
		
	return item

func generate_random_item(is_legendary: bool = false) -> ItemData:
	return generate_random_item_by_stats(6 if is_legendary else randi_range(1, 4))

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
		var item = source_data.item_data[current_index]
		if not item:
			return

		var player: Player = get_tree().root.find_child("Player", true, false)
		if player and player.stats:
			if player.stats.total_gold < item.price:
				print("Not enough gold!")
				return
			else:
				player.stats.total_gold -= item.price

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
		
		# If the target is the player's inventory or equipment, save the game
		if target_data is InventoryData or target_data is EquipmentData:
			var player = get_tree().root.find_child("Player", true, false)
			var inv_window = get_tree().root.find_child("InventoryWindow", true, false)
			if inv_window:
				SaveManager.save_game(inv_window.inventory_data, inv_window.equipment_data, player.stats if player else null)
		
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
		6:
			return Color.ORANGE
		_:
			return Color.WHITE
