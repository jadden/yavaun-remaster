extends Node2D

@onready var racial_ui = $RacialUI  # Référence à l'interface raciale

func _ready():
	"""
	Initialisation de la carte.
	"""
	# Changer la musique
	MusicManager.stop_music()
	MusicManager.play_music("warrior_of_the_wild")

	# Trouver le clan sélectionné
	var current_clan = null
	for clan in ClanManager.clans:
		if clan.uuid == ClanManager.current_clan_id:
			current_clan = clan
			break

	# Vérifier si un clan est sélectionné
	if current_clan == null:
		print("Erreur : Aucun clan sélectionné. Impossible d'initialiser la carte.")
		return

	# Charger les données du clan actuel et les envoyer à l'UI
	print("Clan actuel :", current_clan)

	var clan_data = {
		"leader_name": current_clan.leader_name,
		"leader_image": null,  # À adapter si besoin
		"leader_health": 100,
		"resource_score": 3000
	}
	if racial_ui:
		racial_ui.update_clan_data(clan_data)

	print("Carte initialisée avec le clan :", current_clan.clan_name)
