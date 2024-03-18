class_name GUI
extends CanvasLayer


func update_labels(player: Player):
	$Control/Labels/TimeLabel.text = "Time: %2.3f" % player.level_time_sec
	$Control/Labels/CoinsLabel.text = "Coins: %d" % player.coins
	$Control/Bars/HealthBar.value = 100.0 * player.health / player.max_health
	$Control/Bars/ManaBar.value = 100.0 * player.mana / player.max_mana
