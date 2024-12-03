extends Control

func _on_previous_race_screen_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://ShamaLi/Scenes/ClanScreen.tscn")


func _on_button_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://ShamaLi/Scenes/Campaign1/Scenario1/ScenarioGoal.tscn")
