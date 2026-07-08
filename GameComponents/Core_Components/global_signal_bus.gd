extends Node


signal UpdateInventory
signal PlayerDamaged(amount: float)
signal EnemyKilled(reward: float)

func _ready() -> void:
	print("GSB Ready")
	UpdateInventory.emit()
