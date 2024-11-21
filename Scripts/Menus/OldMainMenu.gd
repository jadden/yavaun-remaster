extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.play_music("main_menu")

func _on_tha_roon_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_confirm_race_sound()
	# Changer la musique
	MusicManager.stop_music()
	MusicManager.play_music("race_screen")
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://ThaRoon/Scenes/RaceScreen.tscn")

func _on_obblinox_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_confirm_race_sound()
	# Changer la musique
	MusicManager.play_music("race_screen")
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://Obblinox/Scenes/RaceScreen.tscn")

func _on_eaggra_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_confirm_race_sound()
	# Changer la musique
	MusicManager.play_music("race_screen")
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://Eaggra/Scenes/RaceScreen.tscn")

func _on_shama_li_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_confirm_race_sound()
	# Changer la musique
	MusicManager.play_music("race_screen")
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://ShamaLi/Scenes/RaceScreen.tscn")
	
func _on_custom_game_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_confirm_race_sound()
	# Changer la musique
	MusicManager.play_music("race_screen")
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://ShamaLi/Scenes/RaceScreen.tscn")
