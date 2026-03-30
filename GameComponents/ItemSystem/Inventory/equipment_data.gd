class_name EquipmentData extends Resource

@export var item_data: Array[ItemData]
@export var inventory_type: Enums.InventoryType = Enums.InventoryType.EQUIPMENT

const SLOT_TYPES: Array[Enums.ItemType] = [
	Enums.ItemType.HELMET,
	Enums.ItemType.AMULET,
	Enums.ItemType.CHEST,
	Enums.ItemType.BELT,
	Enums.ItemType.PANTS,
	Enums.ItemType.BOOTS,
	Enums.ItemType.RING,
	Enums.ItemType.RING
]

func can_equip(item: ItemData, index: int) -> bool:
	if index < 0 or index >= SLOT_TYPES.size():
		return false
	return item.item_type == SLOT_TYPES[index]
