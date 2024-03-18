extends CanvasLayer

var next_level_path := ""


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_next_level_button_pressed() -> void:
	if not next_level_path:
		return
	
	get_tree().change_scene_to_file(next_level_path)


func show_menu(time, coins):
	show()
	$VBoxContainer/LevelTimeLabel.text = "Level Time: %2.3f sec" % time
	$VBoxContainer/CoinsLabel.text = "Coins: %d" % coins
