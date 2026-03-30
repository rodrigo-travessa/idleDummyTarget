extends Node2D

@onready var dps_counter: TextEdit = %DpsCounter
@onready var player: Player = get_tree().root.find_child("Player", true, false)
@onready var item1_slot: ItemSlot = %Item1
@onready var item2_slot: ItemSlot = %Item2
@onready var item_result_slot: ItemSlot = %ItemResult
@onready var combine_button: Button = %CombineButton

var recombinator_data: InventoryData
var damage_history: Array = [] # Array of [timestamp, amount]
var damage_since_item_change: float = 0.0
var time_of_last_item_change: float = 0.0

func _ready() -> void:
	GlobalSignalBus.PlayerDamaged.connect(_on_player_damaged)
	GlobalSignalBus.UpdateInventory.connect(_on_inventory_updated)
	time_of_last_item_change = Time.get_ticks_msec() / 1000.0
	
	setup_recombinator()

func setup_recombinator() -> void:
	recombinator_data = InventoryData.new()
	recombinator_data.item_data.resize(3)
	
	item1_slot.inventory_data = recombinator_data
	item1_slot.index = 0
	
	item2_slot.inventory_data = recombinator_data
	item2_slot.index = 1
	
	item_result_slot.inventory_data = recombinator_data
	item_result_slot.index = 2
	
	combine_button.pressed.connect(_on_combine_pressed)
	_on_inventory_updated()

func _on_combine_pressed() -> void:
	var item1 = recombinator_data.item_data[0]
	var item2 = recombinator_data.item_data[1]
	
	if not item1 or not item2:
		print("Recombinator: Missing item(s)")
		return
	
	# Only allow result if result slot is empty
	if recombinator_data.item_data[2]:
		print("Recombinator: Result slot not empty")
		return
		
	var stats1 = item1.item_stats
	var stats2 = item2.item_stats
	
	var count1 = stats1.size()
	var count2 = stats2.size()
	
	if count1 != count2:
		print("Recombinator: Rarity mismatch (%d vs %d)" % [count1, count2])
		return # Must be same rarity
		
	var result_item = ItemData.new()
	result_item.item_type = item1.item_type # Use type from item1
	result_item.item_texture = item1.item_texture
	result_item.item_amount = 1
	
	var new_stats : Dictionary[Enums.StatId, int] = {}
	
	if count1 == 1: # Normal -> Uncommon
		result_item.item_name = "Uncommon " + item1.item_name
		# Merge stats. If same stat, sum them.
		for s in stats1:
			new_stats[s] = stats1[s]
		for s in stats2:
			if new_stats.has(s):
				new_stats[s] += stats2[s]
			else:
				new_stats[s] = stats2[s]
	elif count1 == 2: # Uncommon -> Rare (3 stats from 4)
		result_item.item_name = "Rare " + item1.item_name
		var all_stats = _get_combined_stats_list(stats1, stats2)
		_pick_random_stats(new_stats, all_stats, 3)
	elif count1 == 3: # Rare -> Epic (4 stats from 6)
		result_item.item_name = "Epic " + item1.item_name
		var all_stats = _get_combined_stats_list(stats1, stats2)
		_pick_random_stats(new_stats, all_stats, 4)
	else:
		print("Recombinator: Unsupported rarity or max reached (%d)" % count1)
		return # Max rarity reached or unknown
		
	result_item.item_stats = new_stats
	print("Recombinator: Success! Created ", result_item.item_name)
	
	recombinator_data.item_data[0] = null
	recombinator_data.item_data[1] = null
	recombinator_data.item_data[2] = result_item
	
	GlobalSignalBus.UpdateInventory.emit()

func _get_combined_stats_list(s1: Dictionary, s2: Dictionary) -> Array:
	var list = []
	for s in s1:
		list.append({"id": s, "val": s1[s]})
	for s in s2:
		list.append({"id": s, "val": s2[s]})
	return list

func _pick_random_stats(target: Dictionary, source_list: Array, count: int) -> void:
	source_list.shuffle()
	var stats_added = 0
	for i in range(source_list.size()):
		if stats_added >= count:
			break
		var stat = source_list[i]
		if target.has(stat.id):
			target[stat.id] += stat.val
			# Don't increment stats_added if it's already there? No, usually in these games, it counts as one "pick".
			# But if we want exactly `count` stat lines in the result, we should try to pick unique IDs first.
		else:
			target[stat.id] = stat.val
			stats_added += 1
	
	# If we haven't reached `count` lines, then it just is what it is because IDs were the same.

func _on_inventory_updated() -> void:
	damage_since_item_change = 0.0
	time_of_last_item_change = Time.get_ticks_msec() / 1000.0
	
	if item1_slot: item1_slot.set_item_slot()
	if item2_slot: item2_slot.set_item_slot()
	if item_result_slot: item_result_slot.set_item_slot()

func _on_player_damaged(amount: float) -> void:
	if player and player.stats:
		player.stats.total_gold += amount
	damage_since_item_change += amount
	damage_history.append([Time.get_ticks_msec() / 1000.0, amount])
	
	# Keep history manageable, say last 60 seconds
	var current_time = Time.get_ticks_msec() / 1000.0
	while damage_history.size() > 0 and current_time - damage_history[0][0] > 60.0:
		damage_history.remove_at(0)

func _process(_delta: float) -> void:
	update_dps_ui()

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
	var text = "Gold: %.0f \n" % current_gold
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

