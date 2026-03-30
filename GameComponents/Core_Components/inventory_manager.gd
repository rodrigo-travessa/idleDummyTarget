extends Node

func equip_item(item_index: int, inventory_data: InventoryData, equipment_data: EquipmentData) -> void:
	var item = inventory_data.item_data[item_index]
	if not item:
		return
	
	# Find correct slot in equipment
	var target_index = -1
	for i in range(EquipmentData.SLOT_TYPES.size()):
		if equipment_data.can_equip(item, i):
			# If it's a ring, we might want to pick an empty slot or just the first one
			if item.item_type == Enums.ItemType.RING:
				if equipment_data.item_data[i] == null:
					target_index = i
					break
				elif target_index == -1:
					target_index = i
			else:
				target_index = i
				break
	
	if target_index != -1:
		var equipped_item = equipment_data.item_data[target_index]
		equipment_data.item_data[target_index] = item
		inventory_data.item_data[item_index] = equipped_item
		
		save_and_update(inventory_data, equipment_data)

func unequip_item(item_index: int, equipment_data: EquipmentData, inventory_data: InventoryData) -> void:
	var item = equipment_data.item_data[item_index]
	if not item:
		return
	
	# Find empty slot in inventory
	var empty_slot = -1
	for i in range(inventory_data.item_data.size()):
		if inventory_data.item_data[i] == null:
			empty_slot = i
			break
	
	if empty_slot != -1:
		inventory_data.item_data[empty_slot] = item
		equipment_data.item_data[item_index] = null
		
		save_and_update(inventory_data, equipment_data)
	else:
		print("Inventory full!")

func save_and_update(inventory_data: InventoryData, equipment_data: EquipmentData) -> void:
	var player = get_tree().root.find_child("Player", true, false)
	SaveManager.save_game(inventory_data, equipment_data, player.stats if player else null)
	GlobalSignalBus.UpdateInventory.emit()