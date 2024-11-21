extends "res://Scenes/Scripts/BaseBuilding.gd"

func _ready():
	building_name = "Hostel"
	cost = 1500
	health = 1500
	max_health = 1500
	time_to_build = 9
	faction = "Shama'Li"
	super()._ready()
