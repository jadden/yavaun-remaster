extends Node2D

func _ready():
	# Changer la musique
	MusicManager.stop_music()
	MusicManager.play_music("warrior_of_the_wild")
	
	print("La carte est prête.")
