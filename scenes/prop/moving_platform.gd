class_name MovingPlatform
extends CharacterBody2D

enum {
	GOING_UP,
	GOING_DOWN,
}

@export var lift_height := 10
@export var move_speed := 50.0

var state := GOING_UP

var _down_height := 0.0
var _up_height := 0.0


func _ready() -> void:
	_down_height = position.y
	_up_height = _down_height - lift_height


func _physics_process(delta: float) -> void:
	velocity.y = move_speed
	velocity.x = 0.0
	
	if position.y < _up_height:
		state = GOING_DOWN
	elif position.y > _down_height:
		state = GOING_UP
	
	match state:
		GOING_DOWN:
			velocity.y = absf(velocity.y)
		GOING_UP:
			velocity.y = -absf(velocity.y)
	
	move_and_slide()
