extends Control

@export var inventory_data: InventoryData
@export var equipment_data: EquipmentData

var item_textures = {
	Enums.ItemType.HELMET: preload("res://GameComponents/ItemSystem/Items/Helmet.png"),
	Enums.ItemType.CHEST: preload("res://GameComponents/ItemSystem/Items/Armor.png"),
	Enums.ItemType.PANTS: preload("res://GameComponents/ItemSystem/Items/pants.png"),
	Enums.ItemType.RING: preload("res://GameComponents/ItemSystem/Items/Ring.png"),
	Enums.ItemType.BELT: preload("res://GameComponents/ItemSystem/Items/belt.png"),
	Enums.ItemType.BOOTS: preload("res://GameComponents/ItemSystem/Items/boots.png"),
	Enums.ItemType.AMULET: preload("res://GameComponents/ItemSystem/Items/amulet.png")
}

var current_dragged_item_data: Dictionary

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
	var save = SaveManager.load_save()
	if save:
		if save.inventory_data:
			inventory_data = save.inventory_data

		if save.equipment_data:
			equipment_data = save.equipment_data

		if equipment_data.item_data.size() != EquipmentData.SLOT_TYPES.size():
			equipment_data = EquipmentData.new()
			equipment_data.item_data.resize(EquipmentData.SLOT_TYPES.size())
	update_inventory_data()
	connect_signals()
	update_stats_display()
	%DeleteInventoryButton.pressed.connect(_on_delete_inventory_button_pressed)

func _on_delete_inventory_button_pressed() -> void:
	if inventory_data and inventory_data.item_data:
		for i in range(inventory_data.item_data.size()):
			inventory_data.item_data[i] = null
	
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.stats:
		player.stats.total_gold = 0
	
	SaveManager.save_game(inventory_data, equipment_data, player.stats if player else null)
	GlobalSignalBus.UpdateInventory.emit()

func update_stats_display() -> void:
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.stats:
		if not player.stats.StatsChanged.is_connected(update_stats_display):
			player.stats.StatsChanged.connect(update_stats_display)
		%CharachterStatsPanel.text = player.stats.get_stat_string()

func connect_signals() -> void:
	GlobalSignalBus.connect("UpdateInventory", update_inventory_data)

func update_inventory_data() -> void:
	update_stats_display()
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
			%SlotGroup.add_child(new_slot)
			new_slot.set_hint_texture(null) # Hide hints in inventory
			inventory_index += 1

	if equipment_data and equipment_data.item_data:
		for item_data in equipment_data.item_data:
			var new_slot = preload("uid://lfclvjuoc48l").instantiate() #ItemSlot UUID
			new_slot.current_item = item_data
			new_slot.index = equipment_index
			new_slot.inventory_data = equipment_data
			
			var slot_type = EquipmentData.SLOT_TYPES[equipment_index]
			if item_textures.has(slot_type):
				new_slot.set_hint_texture(item_textures[slot_type])
				
			equipment_index += 1
			%SlotGroup2.add_child(new_slot)

	var player = get_tree().root.find_child("Player", true, false)
	# Removed intermediate save to avoid voiding items during drag
	# SaveManager.save_game(inventory_data, equipment_data, player.stats if player else null)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		var hovered_node : Control = get_viewport().gui_get_hovered_control()
		if hovered_node is not ItemSlot:
			return
		
		# Only start drag if the slot belongs to this inventory/equipment window
		if hovered_node.get_parent() != %SlotGroup and hovered_node.get_parent() != %SlotGroup2:
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
			
			var player = get_tree().root.find_child("Player", true, false)
			SaveManager.save_game(inventory_data, equipment_data, player.stats if player else null)
			
			current_dragged_item_data = {}
			return

		var target_data = hovered_node.inventory_data
		var target_index = hovered_node.index

		if target_data is EquipmentData and not target_data.can_equip(item, target_index):
			source_data.item_data[index] = item
			GlobalSignalBus.UpdateInventory.emit()
			current_dragged_item_data = {}
			return

		if target_data.item_data[target_index]:
			source_data.item_data[index] = item
			GlobalSignalBus.UpdateInventory.emit()
			current_dragged_item_data = {}
			return

		target_data.item_data[target_index] = item
		GlobalSignalBus.UpdateInventory.emit()
		
		var player = get_tree().root.find_child("Player", true, false)
		SaveManager.save_game(inventory_data, equipment_data, player.stats if player else null)
		
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
