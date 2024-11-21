extends "res://Scenes/Scripts/BaseBuilding.gd"

func _ready():
	building_name = "Outpost"
	cost = 2000
	health = 2000
	max_health = 2000
	time_to_build = 7
	faction = "Shama'Li"
	super()._ready()
