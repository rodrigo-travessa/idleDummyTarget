extends Node


signal UpdateInventory

func _ready() -> void:
	print("GSB Ready")
	UpdateInventory.emit()
