class_name Player
extends CharacterBody2D

const TERMINAL_VELOCITY := 1000.0

@export var jump_force := 200.0
@export var acceleration := 1.0
@export var deceleration := 1.0
@export var move_speed := 100.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var input_vec := Vector2.ZERO

var grounded := false
var attacking := false

var max_health := 100
var health := 100
var max_mana := 100.0
var mana := 100.0
var mana_cost := 50
var mana_replenish_speed := 10.0
var damage := 10

var spawn_point := Vector2.ZERO

var start_time := 0
var level_time_sec := 0.0
var coins := 0

var _ground_rays := []

var _enemies_in_range := []
var _level: Level = null

var _finished := false
var _last_dir_x := 1.0


func _ready() -> void:
	spawn_point = global_position
	$SwordSwoosh.hide()
	start_time = Time.get_ticks_usec()
	
	if get_parent() is Level:
		_level = get_parent()
	
	for child in $GroundRays.get_children():
		if child is RayCast2D:
			_ground_rays.append(child)


func _process(delta: float) -> void:
	if _finished:
		input_vec = Vector2.ZERO
		return
	
	mana += mana_replenish_speed * delta
	mana = minf(max_mana, mana)
	
	input_vec = Input.get_vector("move_left", "move_right", "down", "up")
	var dir_x = input_vec.x
	if absf(dir_x) < 0.1:
		dir_x = _last_dir_x
		
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("magic"):
		magic(dir_x)
	
	level_time_sec += delta
	$GUI.update_labels(self)
	
	_last_dir_x = dir_x


func _physics_process(delta: float) -> void:
	grounded = is_on_floor()
	
	for ray in _ground_rays:
		if ray.is_colliding():
			grounded = true
	
	if abs(input_vec.x) > 0.1:
		$Sprite2D.play("walk")
	else:
		$Sprite2D.stop()
	
	if input_vec.x < 0:
		$Sprite2D.flip_h = true
		$SwordSwoosh.flip_h = true
		$SwordHitbox.position.x = -abs($SwordHitbox.position.x)
		$ProjectileSpawner.position.x = -abs($ProjectileSpawner.position.x)
	elif input_vec.x > 0:
		$Sprite2D.flip_h = false
		$SwordSwoosh.flip_h = false
		$SwordHitbox.position.x = abs($SwordHitbox.position.x)
		$ProjectileSpawner.position.x = abs($ProjectileSpawner.position.x)
	
	if not grounded:
		velocity.y += gravity * delta
	
	if abs(input_vec.x) > 0.1:
		velocity.x += input_vec.x * acceleration
	else:
		velocity = velocity.move_toward(Vector2(0.0, velocity.y), deceleration)
		
	velocity.x = clampf(velocity.x, -move_speed, move_speed)
	velocity.y = clampf(velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
	if Input.is_action_just_pressed("jump") and grounded:
		jump()
	
	move_and_slide()


func jump() -> void:
	velocity.y = 0.0
	velocity.y += -jump_force
	$JumpAudio.play()


func attack():
	$SwordSwoosh.show()
	if $SwordSwoosh.is_playing():
		return
	
	attacking = true
	$SwordAudio.play()
	$SwordSwoosh.play()
	
	for enemy in _enemies_in_range:
		enemy.take_damage(damage)


func magic(dir_sign):
	if not $ProjectileSpawner.can_attack:
		return
	
	if mana < mana_cost:
		return
	
	mana -= mana_cost
	$ProjectileSpawner.attack(dir_sign)
	mana = maxf(mana, 0.0)


func take_damage(dmg) -> void:
	health -= dmg
	if health <= 0:
		health = 0
		_die()


func _die() -> void:
	print_debug("Player died")
	$DeathAudio.play()
	reset()


func reset() -> void:
	health = max_health
	mana = max_mana
	velocity = Vector2.ZERO
	global_position = spawn_point
	_level.reset_enemies()
	_finished = false
	level_time_sec = 0.0
	$ProjectileSpawner.reset()
	
	start_time = Time.get_ticks_usec()
	
	print_debug("Player reset")


func _on_sword_swoosh_animation_finished() -> void:
	$SwordSwoosh.stop()
	$SwordSwoosh.hide()
	attacking = false


func end_level() -> void:
	var level_time_usec := Time.get_ticks_usec() - start_time
	level_time_sec = float(level_time_usec * 0.001 *  0.001)
	_finished = true
	_level.end_level()


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if not body in _enemies_in_range:
			_enemies_in_range.append(body) 


func _on_sword_hitbox_body_exited(body: Node2D) -> void:
	if body in _enemies_in_range:
		_enemies_in_range.erase(body)
