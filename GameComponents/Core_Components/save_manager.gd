extends Node

var path_to_save_file : String = "user://save_game.tres"
var subbed_to_be_saved : Array = []

func _ready() -> void:
	print("SaveManager Loaded")


func save_game(inventory_data : InventoryData, equipment_data: EquipmentData):
	var game_save = SaveData.new()
	#game_save.player_stats = PlayerManager.get_player_stats()
	
	# If the resources have a res:// path, we must duplicate them to save them as internal resources
	# Otherwise, ResourceSaver will save a reference to the res:// path, which is read-only at runtime.
	# We also duplicate resources that have NO resource_path (internal subresources) 
	# to ensure they are properly decoupled from the scene file.
	if inventory_data and (inventory_data.resource_path.begins_with("res://") or inventory_data.resource_path == ""):
		game_save.inventory_data = inventory_data.duplicate()
	else:
		game_save.inventory_data = inventory_data
		
	if equipment_data and (equipment_data.resource_path.begins_with("res://") or equipment_data.resource_path == ""):
		game_save.equipment_data = equipment_data.duplicate()
	else:
		game_save.equipment_data = equipment_data
		
	var error = ResourceSaver.save(game_save, path_to_save_file)
	if error != OK:
		print("Error saving game: ", error)
	else:
		print("Game saved successfully to: ", path_to_save_file)


#func load_player_stats() -> PlayerStats:
	#var loaded_save : SaveData = ResourceLoader.load(path_to_save_file) as SaveData
	#if loaded_save:
		#return loaded_save.player_stats as PlayerStats
	#else:
		#print("No save file found, returning new PlayerStats")
		#return PlayerStats.new()

func load_save() -> SaveData:
	if not FileAccess.file_exists(path_to_save_file):
		print("No save file found at: ", path_to_save_file)
		return null
	
	var loaded_save : SaveData = ResourceLoader.load(path_to_save_file, "", ResourceLoader.CACHE_MODE_REPLACE) as SaveData
	if loaded_save:
		print("Save file loaded successfully from: ", path_to_save_file)
		return loaded_save
	else:
		print("Failed to load save file at: ", path_to_save_file)
		return null

func sub_to_be_saved(node):
	subbed_to_be_saved.append(node)
