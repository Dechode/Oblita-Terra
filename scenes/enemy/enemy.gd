class_name Enemy
extends CharacterBody2D

const PROJECTILE_WEAPON = preload("res://scenes/weapon/projectile_weapon.tscn")

enum state {
	IDLE,
	ATTACKING,
	DEAD,
}

@export var health := 100

var _spawn_position := Vector2.ZERO
var _spawn_health := 100

var _player: Player = null
var _current_state := state.IDLE

var _can_attack := true

@onready var projectile_spawner = $ProjectileSpawner


func _ready() -> void:
	_spawn_health = health
	_spawn_position = global_position


func _process(delta: float) -> void:
	if _current_state == state.IDLE:
		return
	elif _current_state == state.ATTACKING:
		if not _player:
			push_error("No player reference")
			return
		var dir_sign := 1.0
		if _player.global_position.x < global_position.x:
			$EnemySprite.flip_h = true
			dir_sign = -1.0
			projectile_spawner.position.x = -absf(projectile_spawner.position.x)
		else:
			$EnemySprite.flip_h = false
			dir_sign = 1.0
			projectile_spawner.position.x = absf(projectile_spawner.position.x)
		
		attack(dir_sign)
	elif _current_state == state.DEAD:
		pass
	else:
		print_debug("Unknown state")


func take_damage(dmg) -> void:
	if _current_state == state.DEAD:
		return
	
	health -= dmg
	if health <= 0:
		_die()


func attack(p_dir_sign):
	if not _can_attack:
		return
		
	$EnemySprite.play("attack")
	projectile_spawner.attack(p_dir_sign)
	$AttackCooldownTimer.start()
	_can_attack = false


func _die() -> void:
	health = 0
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	_current_state = state.DEAD


func reset():
	health = _spawn_health
	global_position = _spawn_position
	$CollisionShape2D.set_deferred("disabled", false)
	projectile_spawner.reset()
	show()
	_current_state = state.IDLE


func _on_player_check_body_entered(body: Node2D) -> void:
	if _current_state == state.DEAD:
		return
	
	if body is Player:
		_player = body
		_current_state = state.ATTACKING
		print_debug("Player found, attacking")


func _on_player_check_body_exited(body: Node2D) -> void:
	if _current_state == state.DEAD:
		return
	if body is Player:
		_player = null
		_current_state = state.IDLE
		print_debug("Player left, idling")


func _on_attack_cooldown_timer_timeout() -> void:
	if _current_state == state.DEAD:
		return
	_can_attack = true
