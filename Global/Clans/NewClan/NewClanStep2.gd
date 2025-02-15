extends Control

@onready var leader_name_input = $VBoxContainer/LeaderNameInput
@onready var clan_name_input = $VBoxContainer/ClanNameInput
@onready var create_clan_button = $VBoxContainer/CreateClanButton
@onready var back_button = $VBoxContainer/BackButton  # Vérifiez ce chemin dans l'éditeur

func _ready():
	"""
	Initialise les entrées et les boutons.
	"""
	if not back_button or not create_clan_button:
		print("Erreur : Un ou plusieurs nœuds sont manquants.")
		return

	# Connecter les signaux
	create_clan_button.pressed.connect(_on_CreateClanButton_pressed)
	back_button.pressed.connect(_on_BackButton_pressed)

	# Préremplir les champs
	var race = ClanManager.current_race
	if race != "":
		var default_names = get_default_names(race)
		leader_name_input.text = default_names["leader_name"]
		clan_name_input.text = default_names["clan_name"]
	else:
		print("Erreur : Aucune race sélectionnée.")

func _on_CreateClanButton_pressed():
	"""
	Crée un nouveau clan.
	"""
	var leader_name = leader_name_input.text.strip_edges()
	var clan_name = clan_name_input.text.strip_edges()
	var race = ClanManager.current_race

	if leader_name == "" or clan_name == "":
		print("Erreur : Le nom du leader et du clan ne peuvent pas être vides.")
		return

	if race == "":
		print("Erreur : Aucune race sélectionnée.")
		return

	# Charger les clans existants avant d'ajouter un nouveau clan
	ClanManager.load_clans()

	var clan_color = get_clan_color(race)
	var new_clan = ClanManager.GameClan.new(clan_name, leader_name, race, clan_color)
	ClanManager.add_clan(new_clan)

	print("Nouveau clan créé :", clan_name, "-", leader_name)

	# Sauvegarder et changer de scène
	ClanManager.save_clans()
	get_tree().change_scene_to_file("res://Global/Clans/ClanList.tscn")

func _on_BackButton_pressed():
	"""
	Retourne à l'étape précédente.
	"""
	get_tree().change_scene_to_file("res://Global/Clans/NewClan/NewClanStep1.tscn")

func get_default_names(race: String) -> Dictionary:
	"""
	Retourne les noms par défaut en fonction de la race.
	"""
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

func get_clan_color(race: String) -> Color:
	"""
	Retourne la couleur associée à la race.
	"""
	match race:
		"Tha'Roon": return Color(0, 0, 1)  # Bleu
		"Obblinox": return Color(1, 0, 0)  # Rouge
		"Eaggra": return Color(0, 1, 0)  # Vert
		"Shama'Li": return Color(1, 1, 0)  # Jaune
		_: return Color(1, 1, 1)  # Blanc
