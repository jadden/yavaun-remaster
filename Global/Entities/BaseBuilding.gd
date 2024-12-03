extends Node2D
class_name BaseBuilding

@export var building_name: String = ""
@export var health: int = 500
@export var max_health: int = 500
@export var cost: int = 3000
@export var time_to_build: int = 1
@export var faction: String = ""
@export var is_selected: bool = false

func set_selected(is_selected: bool):
	self.is_selected = is_selected
	# Ajoutez une logique pour afficher une sélection visuelle si nécessaire

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
