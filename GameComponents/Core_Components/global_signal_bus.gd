extends Node


signal UpdateInventory
signal PlayerDamaged(amount: float)

func _ready() -> void:
	print("GSB Ready")
	UpdateInventory.emit()
