extends "res://Global/Entities/BaseBuilding.gd"

func _ready():
	building_name = "Sanctuary"
	cost = 2750
	health = 2750
	max_health = 2750
	time_to_build = 10
	faction = "Shama'Li"
	super()._ready()
