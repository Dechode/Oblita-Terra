class_name MainMenu
extends Control

var selected_level_path := ""


func _ready() -> void:
	$HBoxContainer/Levels.hide()
	$HBoxContainer/StartScreen.hide()
	
	var level_buttons := $HBoxContainer/Levels/LevelButtons.get_children()
	
	for i in range(GameManager.level_count):
		if i > GameManager.config.unlocked_levels - 1:
			level_buttons[i].disabled = true
	
	update_coins_label()


func update_coins_label() -> void:
	$CoinsLabel.text = "Coins: %d" % GameManager.config.coins


func _on_play_button_pressed() -> void:
	$HBoxContainer/Levels.visible = not $HBoxContainer/Levels.visible
	$HBoxContainer/StartScreen.visible = not $HBoxContainer/StartScreen.visible


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	if selected_level_path:
		get_tree().change_scene_to_file(selected_level_path)


func _on_level_selected(level_number: int) -> void:
	var path := "res://scenes/levels/level"
	path += str(level_number)
	path += ".tscn"
	selected_level_path = path
	
	var time = 0.0
	
	if GameManager.config.high_scores[level_number - 1].size() > 0:
		time = GameManager.config.high_scores[level_number - 1][0]
	
	$HBoxContainer/StartScreen/BestTimeLabel.text = "Best Time: %2.3f" % time
		
