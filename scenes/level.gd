class_name Level
extends Node2D

const LEVEL_END_MENU = preload("res://scenes/menu/level_end_menu.tscn")

@export var level_number := 1

var enemies := []
var player: Player = null

var _level_end_menu_instance = null
var _level_base_path := "res://scenes/levels/level"


func _ready() -> void:
	for child in get_children():
		if child is Enemy:
			enemies.append(child)
		elif child is Player:
			player = child
		
		# Maybe needed for occasional collision issues with tilemap?
		#elif child is TileMap:
			#child.position = child.position
	
	_level_end_menu_instance = LEVEL_END_MENU.instantiate()
	if level_number < GameManager.level_count:
		_level_end_menu_instance.next_level_path = _level_base_path + str(level_number + 1) +  ".tscn"
	else:
		_level_end_menu_instance.next_level_path = "res://scenes/main_menu.tscn"
	add_child(_level_end_menu_instance)
	_level_end_menu_instance.hide()


func reset_level():
	reset_enemies()
	player.reset()


func reset_enemies() -> void:
	for enemy in enemies:
		enemy.reset()


func end_level() -> void:
	_level_end_menu_instance.show_menu(player.level_time_sec, player.coins)
	
	GameManager.add_coins(player.coins)
	GameManager.add_new_score(self, player.level_time_sec)
	GameManager.unlock_new_level(self)
	
	print_debug("Level took %2.2f sec" % player.level_time_sec)
