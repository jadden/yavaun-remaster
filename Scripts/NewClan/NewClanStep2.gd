extends Control

@onready var leader_name_input = $VBoxContainer/LeaderNameInput
@onready var clan_name_input = $VBoxContainer/ClanNameInput
@onready var create_clan_button = $VBoxContainer/CreateClanButton

func _ready():
	# Vérifier que ClanManager est bien accessible
	if not Engine.has_singleton("ClanManager"):
		print("Erreur : ClanManager n'est pas configuré comme singleton.")
		return

	# Préremplir les champs avec des valeurs par défaut
	var race = ClanManager.current_race
	if race != "":
		var default_names = get_default_names(race)
		leader_name_input.text = default_names["leader_name"]
		clan_name_input.text = default_names["clan_name"]

	# Connecter le bouton de création de clan
	create_clan_button.pressed.connect(_on_CreateClanButton_pressed)

func _on_CreateClanButton_pressed():
	var leader_name = leader_name_input.text.strip_edges()
	var clan_name = clan_name_input.text.strip_edges()
	var race = ClanManager.current_race

	if leader_name != "" and clan_name != "":
		var clan_color = get_clan_color(race)
		var new_clan = ClanManager.Clan.new(clan_name, leader_name, race, clan_color)
		ClanManager.add_clan(new_clan)
		ClanManager.save_clans()
		get_tree().change_scene_to_file("res://Scenes/GoToClan/ClanList.tscn")
	else:
		print("Erreur : Le nom du leader et du clan ne peuvent pas être vides.")

func get_default_names(race: String) -> Dictionary:
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
			return Color(1, 1, 1)  # Blanc
