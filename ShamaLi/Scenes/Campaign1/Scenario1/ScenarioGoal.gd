extends Control

func _on_previous_race_screen_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Retourner à l'écran d'entrée
	get_tree().change_scene_to_file("res://ShamaLi/Scenes/Campaign1/Scenario1/EntryScreen.tscn")

func _on_launch_game_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()

	# Charger GlobalMap
	var global_map_scene = load("res://Global/GlobalMap.tscn")  # Chargez la scène, pas le script
	if not global_map_scene:
		print("Erreur : Impossible de charger la scène GlobalMap.")
		return

	var global_map_instance = global_map_scene.instantiate()
	global_map_instance.name = "GlobalMap"
	get_tree().root.add_child(global_map_instance)

	# Charger la première carte avec la race sélectionnée
	global_map_instance.load_map(
		"res://ShamaLi/Scenes/Campaign1/Scenario1/Map.tscn",
		"Shama'Li"
	)
