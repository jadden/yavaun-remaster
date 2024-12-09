extends Node

# Joue un son donné par un chemin
func play_sound_from_path(sound_path: String) -> void:
	if sound_path.strip_edges() == "":  # Vérifie si la chaîne est vide
		return
	var sound_resource = ResourceLoader.load(sound_path)
	if sound_resource and sound_resource is AudioStream:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = sound_resource
		player.autoplay = false
		# Connecte le signal "finished" pour supprimer le player
		player.connect("finished", Callable(player, "queue_free"))
		player.play()
	else:
		print("Erreur : Impossible de charger ou jouer le son depuis le chemin :", sound_path)

# Joue un son de clic
func play_click_sound():
	$ClickSoundPlayer.stop()
	$ClickSoundPlayer.play()

# Joue un son de confirmation de race
func play_confirm_race_sound():
	$ConfirmRacePlayer.stop()
	$ConfirmRacePlayer.play()

# Joue un son pour un choix de menu
func play_menu_choice_sound():
	$MenuChoicePlayer.stop()
	$MenuChoicePlayer.play()
