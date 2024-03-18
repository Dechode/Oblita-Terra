class_name LevelButton
extends Button

signal level_selected(level_number: int)

@export var _level_number := 1


func _ready() -> void:
	pressed.connect(_on_level_button_pressed)


func _on_level_button_pressed():
	level_selected.emit(_level_number)
