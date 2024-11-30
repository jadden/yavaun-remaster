extends Control

@onready var tha_roon_button = $VBoxContainer/HBoxContainer/ThaRoonButton
@onready var obblinox_button = $VBoxContainer/HBoxContainer/ObblinoxButton
@onready var eaggra_button = $VBoxContainer/HBoxContainer/EaggraButton
@onready var shama_li_button = $VBoxContainer/HBoxContainer/ShamaLiButton
@onready var next_button = $VBoxContainer/NextButton
@onready var back_button = $VBoxContainer/BackButton

var selected_race: String = ""

func _ready():
	# Connecter les boutons
	tha_roon_button.pressed.connect(self._on_ThaRoonButton_pressed)
	obblinox_button.pressed.connect(self._on_ObblinoxButton_pressed)
	eaggra_button.pressed.connect(self._on_EaggraButton_pressed)
	shama_li_button.pressed.connect(self._on_ShamaLiButton_pressed)
	next_button.pressed.connect(self._on_NextButton_pressed)
	back_button.pressed.connect(self._on_BackButton_pressed)

func _on_ThaRoonButton_pressed():
	selected_race = "Tha'Roon"
	highlight_selected_race()

func _on_ObblinoxButton_pressed():
	selected_race = "Obblinox"
	highlight_selected_race()

func _on_EaggraButton_pressed():
	selected_race = "Eaggra"
	highlight_selected_race()

func _on_ShamaLiButton_pressed():
	selected_race = "Shama'Li"
	highlight_selected_race()

func highlight_selected_race():
	print("Race sélectionnée :", selected_race)

func _on_NextButton_pressed():
	if selected_race != "":
		ClanManager.current_race = selected_race
		get_tree().change_scene_to_file("res://Scenes/NewClan/NewClanStep2.tscn")
	else:
		print("Veuillez sélectionner une race avant de continuer.")

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
