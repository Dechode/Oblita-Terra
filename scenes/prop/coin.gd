class_name Coin
extends Area2D

var value := 10


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.coins += value
		queue_free()
