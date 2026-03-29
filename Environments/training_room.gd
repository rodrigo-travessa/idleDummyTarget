extends Node2D

@onready var dps_counter: TextEdit = %DpsCounter
@onready var player: Player = get_tree().root.find_child("Player", true, false)

var damage_history: Array = [] # Array of [timestamp, amount]
var damage_since_item_change: float = 0.0
var time_of_last_item_change: float = 0.0

func _ready() -> void:
	GlobalSignalBus.PlayerDamaged.connect(_on_player_damaged)
	GlobalSignalBus.UpdateInventory.connect(_on_inventory_updated)
	time_of_last_item_change = Time.get_ticks_msec() / 1000.0

func _process(_delta: float) -> void:
	update_dps_ui()

func _on_player_damaged(amount: float) -> void:
	if player and player.stats:
		player.stats.total_gold += amount
	damage_since_item_change += amount
	damage_history.append([Time.get_ticks_msec() / 1000.0, amount])
	
	# Keep history manageable, say last 60 seconds
	var current_time = Time.get_ticks_msec() / 1000.0
	while damage_history.size() > 0 and current_time - damage_history[0][0] > 60.0:
		damage_history.remove_at(0)

func _on_inventory_updated() -> void:
	damage_since_item_change = 0.0
	time_of_last_item_change = Time.get_ticks_msec() / 1000.0

func update_dps_ui() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	var damage_1s = get_damage_in_window(current_time, 1.0)
	var damage_5s = get_damage_in_window(current_time, 5.0)
	var damage_30s = get_damage_in_window(current_time, 30.0)
	
	var dps_1s = damage_1s / 1.0
	var dps_5s = damage_5s / 5.0
	var dps_30s = damage_30s / 30.0
	
	var time_since_item_change = max(0.001, current_time - time_of_last_item_change)
	var dps_item_change = damage_since_item_change / time_since_item_change
	
	var current_gold = player.stats.total_gold if player and player.stats else 0.0
	var text = "Gold: %s \n" % current_gold
	text += "DPS: %.2f\n" % dps_1s
	text += "Dps Last 5 seconds: %.2f\n" % dps_5s
	text += "Dps Last 30 seconds %.2f\n" % dps_30s
	
	dps_counter.text = text

func get_damage_in_window(current_time: float, window_seconds: float) -> float:
	var total = 0.0
	for i in range(damage_history.size() - 1, -1, -1):
		var hit = damage_history[i]
		if current_time - hit[0] <= window_seconds:
			total += hit[1]
		else:
			break
	return total

