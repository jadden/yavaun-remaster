extends Control

@onready var leader_name_input = $VBoxContainer/LeaderNameInput
@onready var clan_name_input = $VBoxContainer/ClanNameInput
@onready var create_clan_button = $VBoxContainer/CreateClanButton

func _ready():
	create_clan_button.pressed.connect(self._on_CreateClanButton_pressed)
	
	# Préremplir les champs en fonction de la race sélectionnée
	var race = GameData.race
	var default_names = get_default_names(race)
	leader_name_input.text = default_names.leader_name
	clan_name_input.text = default_names.clan_name

func _on_CreateClanButton_pressed():
	# Jouer le son de clic via le SoundManager
	SoundManager.play_click_sound()
		
	var leader_name = leader_name_input.text.strip_edges()
	var clan_name = clan_name_input.text.strip_edges()
	var race = GameData.race

	if leader_name != "" and clan_name != "":
		# Créer un nouveau profil de clan (ClanProfile)
		var clan_color = get_clan_color(race)
		var clan_icon = get_clan_icon(race)
		var profile = GameData.ClanProfile.new(clan_color, clan_icon)

		# Ajouter le clan à GameData
		GameData.add_clan(clan_name, leader_name, race, profile)

		# Sauvegarder les clans
		GameData.save_clans()

		# Retourner au menu principal ou changer de scène vers le clan
		get_tree().change_scene_to_file("res://Scenes/GoToClan/ClanList.tscn")
	else:
		# Afficher un message d'erreur si les champs sont vides
		print("Erreur : Le nom du leader et du clan ne peuvent pas être vides.")
		# Vous pouvez utiliser une boîte de dialogue pour informer l'utilisateur

func get_default_names(race):
	match race:
		"Tha'Roon":
			return { "leader_name": "Druk Angrak", "clan_name": "House Mondra" }
		"Obblinox":
			return { "leader_name": "Saw'Sha", "clan_name": "Rusty Thunders" }
		"Eaggra":
			return { "leader_name": "Colonel Khorn", "clan_name": "Faction E19" }
		"Shama'Li":
			return { "leader_name": "Jan Akka'", "clan_name": "Agro Defense" }
		_:
			return { "leader_name": "Default Leader", "clan_name": "Default Clan" }

func get_clan_color(race):
	match race:
		"Tha'Roon":
			return Color(1, 0, 0)  # Rouge
		"Obblinox":
			return Color(0, 1, 0)  # Vert
		"Eaggra":
			return Color(0, 0, 1)  # Bleu
		"Shama'Li":
			return Color(1, 1, 0)  # Jaune
		_:
			return Color(1, 1, 1)  # Blanc par défaut

func get_clan_icon(race):
	match race:
		"Tha'Roon":
			return preload("res://ThaRoon/Assets/Portraits/tharoon.png")
		"Obblinox":
			return preload("res://Obblinox/Assets/Portraits/obblinox.png")
		"Eaggra":
			return preload("res://Eaggra/Assets/Portraits/eaggra.png")
		"Shama'Li":
			return preload("res://ShamaLi/Assets/Portraits/shamali.png")
		_:
			return null  # Ou une icône par défaut
