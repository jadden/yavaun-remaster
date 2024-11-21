extends "res://Scenes/Scripts/BaseBuilding.gd"

func _ready():
	building_name = "Guild House"
	cost = 1750
	health = 1750
	max_health = 1750
	time_to_build = 8
	faction = "Shama'Li"
	super()._ready()
