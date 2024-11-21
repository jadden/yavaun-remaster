extends "res://Scenes/Scripts/BaseBuilding.gd"

func _ready():
	building_name = "Temple"
	cost = 2250
	health = 2250
	max_health = 2250
	time_to_build = 10
	faction = "Shama'Li"
	super()._ready()
