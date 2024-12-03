# res://Scripts/MainMenu.gd
extends Control

@onready var new_clan_button = $VBoxContainer/NewClanButton
@onready var go_to_clan_button = $VBoxContainer/GoToClanButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	# Vérifier si la musique "main_menu" est déjà active
	if not MusicManager.is_music_playing("main_menu"):
		MusicManager.play_music("main_menu")
	
	# Connecter les signaux des boutons
	new_clan_button.pressed.connect(_on_NewClanButton_pressed)
	go_to_clan_button.pressed.connect(_on_GoToClanButton_pressed)
	options_button.pressed.connect(_on_OptionsButton_pressed)
	credits_button.pressed.connect(_on_CreditsButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)

func _on_NewClanButton_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Changer de scène vers NewClanStep1.tscn
	get_tree().change_scene_to_file("res://Global/Clans/NewClan/NewClanStep1.tscn")

func _on_GoToClanButton_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Changer de scène vers ClanList.tscn
	get_tree().change_scene_to_file("res://Global/Clans/ClanList.tscn")

func _on_OptionsButton_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Logique pour ouvrir les options
	print("Options sélectionnées")
	# get_tree().change_scene_to_file("res://Scenes/Options.tscn")

func _on_CreditsButton_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	# Logique pour afficher les crédits
	print("Crédits sélectionnés")
	# get_tree().change_scene_to_file("res://Scenes/Credits.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
