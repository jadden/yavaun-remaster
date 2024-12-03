extends "res://Global/Entities/BaseBuilding.gd"

func _ready():
	building_name = "Shelter"
	cost = 600
	health = 600
	max_health = 600
	time_to_build = 5
	faction = "Shama'Li"
	super()._ready()
