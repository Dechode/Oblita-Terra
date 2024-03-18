class_name ProjectileSpawner
extends Node2D

@export var projectile_path := "res://scenes/projectile_weapon.tscn"

var projectiles := []
var can_attack := true

var _projectile_scene = null
var _cooldown_timer := Timer.new()


func _ready() -> void:
	add_child(_cooldown_timer)
	_cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	_projectile_scene = load(projectile_path)


func attack(dir_sign):
	if not can_attack:
		return
	
	var projectile = _projectile_scene.instantiate() as Projectile
	projectile.global_position = global_position
	get_tree().root.add_child(projectile)
	projectile.destroyed.connect(_on_projectile_destroyed)
	
	_cooldown_timer.start(projectile.cooldown)
	projectile.attack(dir_sign)
	
	projectiles.append(projectile)
	can_attack = false


func reset():
	var temp := []
	for projectile in projectiles:
		temp.append(projectile)
	projectiles.clear()
	for p in temp:
		if is_instance_valid(p):
			p.queue_free()


func _on_projectile_destroyed(body: Node2D):
	if not body in projectiles:
		push_warning("Projectile was not in ProjectileSpawners projectiles array ")
		return
	
	print_debug("Projectile was destroyed, ", body)
	projectiles.erase(body)


func _on_cooldown_timer_timeout():
	can_attack = true
