extends Control

@onready var tha_roon_button = $VBoxContainer/HBoxContainer/ThaRoonButton
@onready var obblinox_button = $VBoxContainer/HBoxContainer/ObblinoxButton
@onready var eaggra_button = $VBoxContainer/HBoxContainer/EaggraButton
@onready var shama_li_button = $VBoxContainer/HBoxContainer/ShamaLiButton
@onready var next_button = $VBoxContainer/NextButton
@onready var back_button = $VBoxContainer/BackButton

var selected_race: String = ""

func _ready():
	tha_roon_button.pressed.connect(self._on_ThaRoonButton_pressed)
	obblinox_button.pressed.connect(self._on_ObblinoxButton_pressed)
	eaggra_button.pressed.connect(self._on_EaggraButton_pressed)
	shama_li_button.pressed.connect(self._on_ShamaLiButton_pressed)
	next_button.pressed.connect(self._on_NextButton_pressed)
	back_button.pressed.connect(self._on_BackButton_pressed)

func _on_ThaRoonButton_pressed():
	selected_race = "Tha'Roon"
	show_race_presentation()

func _on_ObblinoxButton_pressed():
	selected_race = "Obblinox"
	show_race_presentation()

func _on_EaggraButton_pressed():
	selected_race = "Eaggra"
	show_race_presentation()

func _on_ShamaLiButton_pressed():
	selected_race = "Shama'Li"
	show_race_presentation()

func show_race_presentation():
	var presentation_scene = preload("res://Scenes/NewClan/RacePresentation.tscn")
	var presentation_instance = presentation_scene.instantiate()
	add_child(presentation_instance)
	if presentation_instance.has_method("set_race"):
		presentation_instance.set_race(selected_race)
		if presentation_instance is Popup:
			presentation_instance.popup_centered()
		else:
			presentation_instance.visible = true  # Affiche la présentation si ce n'est pas un Popup
	else:
		print("Erreur : La scène de présentation ne possède pas la méthode 'set_race'.")

func _on_NextButton_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
	if selected_race != "":
		# Stocker la race sélectionnée dans GameData
		GameData.race = selected_race
		# Charger le profil du clan basé sur la race
		var profile = GameData.load_clan_profile()
		# Changer la musique
		MusicManager.play_music("race_screen")
		# Jouer le son de confirmation via le SoundManager
		SoundManager.play_confirm_race_sound()
		# Changer de scène vers NewClanStep2.tscn
		get_tree().change_scene_to_file("res://Scenes/NewClan/NewClanStep2.tscn")
	else:
		show_error_dialog("Veuillez sélectionner une race avant de continuer.")

func _on_BackButton_pressed():
	# Retourner au menu principal
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func show_error_dialog(message: String):
	var dialog_scene = preload("res://Scenes/Dialogs/MessageDialog.tscn")
	var dialog_instance = dialog_scene.instantiate()
	add_child(dialog_instance)
	if dialog_instance.has_method("set_message"):
		dialog_instance.set_message(message, GameData.MessageType.ERROR)
		if dialog_instance is Popup:
			dialog_instance.popup_centered()
		else:
			dialog_instance.visible = true  # Affiche la boîte de dialogue si ce n'est pas un Popup
	else:
		print("Erreur : La scène de dialogue ne possède pas la méthode 'set_message'.")
