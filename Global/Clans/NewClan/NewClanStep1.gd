extends Control

@onready var tha_roon_button = $VBoxContainer/HBoxContainer/ThaRoon/ThaRoonButton
@onready var obblinox_button = $VBoxContainer/HBoxContainer/Obblinox/ObblinoxButton
@onready var eaggra_button = $VBoxContainer/HBoxContainer/Eaggra/EaggraButton
@onready var shama_li_button = $VBoxContainer/HBoxContainer/ShamaLi/ShamaLiButton
@onready var next_button = $VBoxContainer/NextButton
@onready var back_button = $VBoxContainer/BackButton

var selected_race: String = ""

func _ready():
	"""
	Initialise les boutons et les connecte.
	"""
	tha_roon_button.pressed.connect(_on_ThaRoonButton_pressed)
	obblinox_button.pressed.connect(_on_ObblinoxButton_pressed)
	eaggra_button.pressed.connect(_on_EaggraButton_pressed)
	shama_li_button.pressed.connect(_on_ShamaLiButton_pressed)
	next_button.pressed.connect(_on_NextButton_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)

func _on_ThaRoonButton_pressed():
	_set_selected_race("Tha'Roon")

func _on_ObblinoxButton_pressed():
	_set_selected_race("Obblinox")

func _on_EaggraButton_pressed():
	_set_selected_race("Eaggra")

func _on_ShamaLiButton_pressed():
	_set_selected_race("Shama'Li")

func _set_selected_race(race: String):
	"""
	Change la race sélectionnée et met en surbrillance le bouton correspondant.
	"""
	selected_race = race
	highlight_selected_race()
	print("Race sélectionnée :", selected_race)

func highlight_selected_race():
	"""
	Met en surbrillance le bouton de la race sélectionnée.
	"""
	var buttons = {
		"Tha'Roon": tha_roon_button,
		"Obblinox": obblinox_button,
		"Eaggra": eaggra_button,
		"Shama'Li": shama_li_button
	}

	for race_name in buttons.keys():
		buttons[race_name].modulate = Color(1, 1, 1)  # Réinitialise la couleur
	if buttons.has(selected_race):
		buttons[selected_race].modulate = Color(0.8, 0.8, 1)  # Met en surbrillance

func _on_NextButton_pressed():
	"""
	Passe à l'étape suivante si une race est sélectionnée.
	"""
	if selected_race != "":
		ClanManager.current_race = selected_race
		get_tree().change_scene_to_file("res://Global/Clans/NewClan/NewClanStep2.tscn")
	else:
		print("Veuillez sélectionner une race avant de continuer.")

func _on_BackButton_pressed():
	"""
	Retourne au menu principal.
	"""
	get_tree().change_scene_to_file("res://Global/Menus/MainMenu.tscn")
