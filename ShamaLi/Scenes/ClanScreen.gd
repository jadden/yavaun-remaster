extends Control

func _on_ready():
	# Changer la musique
	MusicManager.stop_music()
	MusicManager.play_music("race_screen")

func _on_previous_screen_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_menu_choice_sound()
	# Réinitialiser le thème et le curseur par défaut
	ThemeManager.reset_to_default()
	# Changer la musique
	MusicManager.stop_music()
	MusicManager.play_music("main_menu")
	# Changer de scène pour aller à l'écran de campagne
	get_tree().change_scene_to_file("res://Global/Menus/MainMenu.tscn")


func _on_leader_name_input_focus_exited():
	var leader_name = $InputsContainer/HBoxContainer/LeaderNameInputContainer/LeaderNameInput.text
	if leader_name.strip_edges() == "":
		leader_name = "Jan Akka'"
		$InputsContainer/HBoxContainer/LeaderNameInputContainer/LeaderNameInput.text = "Druk Angrak"
	PlayerData.leader_name = leader_name
	print("Leader's Name :", PlayerData.leader_name)


func _on_line_edit_focus_exited():
	var clan_name = $InputsContainer/HBoxContainer/ClanNameInputContainer/ClanNameInput.text
	if clan_name.strip_edges() == "":
		clan_name = "Agro Defense"
		$InputsContainer/HBoxContainer/ClanNameInputContainer/ClanNameInput.text = "House Mondra"
	PlayerData.leader_name = clan_name
	print("Clan's Name :", PlayerData.clan_name)


func _on_new_campagn_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	SoundManager.play_confirm_race_sound()
	# Charger la scène du premier scénario
	get_tree().change_scene_to_file("res://ShamaLi/Scenes/Campaign1/Scenario1/EntryScreen.tscn")
