extends Node

var level_count := 9
var config := GameConfig.new()


func _ready() -> void:
	load_config()
	
	if config.high_scores.size() != level_count:
		config.high_scores.resize(level_count)
		for i in range(level_count):
			config.high_scores[i] = []
		
		save_config()
		print_debug("No existing high scores found")
	
	print_debug(config.high_scores)


func add_new_score(level: Level, time: float):
	if level.level_number > config.high_scores.size():
		push_error("Error: Cant add high score to a level number higher than level count")
		return
	
	config.high_scores[level.level_number - 1].append(time)
	config.high_scores[level.level_number - 1].sort()
	save_config()


func add_coins(amount: int):
	if amount < 0:
		amount = absi(amount)
	config.coins += amount
	save_config()


func unlock_new_level(current_level: Level):
	if current_level.level_number == config.unlocked_levels:
		config.unlocked_levels += 1
		save_config()


func load_config():
	var config_path := "user://config.tres"
	if ResourceLoader.exists(config_path):
		config = ResourceLoader.load(config_path)
	else:
		config = GameConfig.new()
		save_config()


func save_config():
	var config_path := "user://config.tres"
	ResourceSaver.save(config, config_path)
