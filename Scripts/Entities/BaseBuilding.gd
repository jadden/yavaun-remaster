extends Node2D
class_name BaseBuilding

var building_name = ""
var health = 500
var max_health = 500
var cost = 3000
var time_to_build = 1
var faction = ""
var selected = false

func _ready():
	pass

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()  # Supprime le bâtiment de la scène
