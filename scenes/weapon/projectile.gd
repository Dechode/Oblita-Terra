class_name Projectile
extends CharacterBody2D

signal destroyed(body)

@export var damage := 20
@export var cooldown := 1.0
@export var lifetime := 5.0
@export var move_speed := 50.0

var _launched := false
var _target_direction := 1.0

#func _ready() -> void:


func _physics_process(delta: float) -> void:
	if not _launched:
		return
	
	velocity.x = move_speed * _target_direction
	move_and_slide()


func attack(dir_sign):
	if _launched:
		return
	
	_launched = true
	_target_direction = dir_sign
	$LifeTimeTimer.start()


func _on_life_time_timer_timeout() -> void:
	destroyed.emit(self)
	queue_free()


func _on_hit_area_body_entered(body: Node2D) -> void:
	destroyed.emit(self)
	if body is Player or body is Enemy:
		body.take_damage(damage)
	if body is Projectile:
		body.queue_free()
	queue_free()

