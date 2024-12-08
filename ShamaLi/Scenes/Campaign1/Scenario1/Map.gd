extends Node2D

@onready var entities_container = $EntitiesContainer
@onready var player_units = $EntitiesContainer/PlayerUnits
@onready var ai_units = $EntitiesContainer/AIUnits
@onready var wild_units = $EntitiesContainer/WildUnits

var racial_ui: Node = null  # Référence à l'interface raciale
var player_id: String = "Player1"  # ID du joueur actuel

func _ready():
	"""
	Initialisation de la carte et des unités.
	"""
	MusicManager.stop_music()
	MusicManager.play_music("warrior_of_the_wild")

	# Vérification des conteneurs
	if not entities_container:
		print("Erreur : EntitiesContainer introuvable.")
		return
	if not player_units or not ai_units or not wild_units:
		print("Erreur : Un des sous-conteneurs d'unités est introuvable.")
		return

	# Charger le clan actuel
	var current_clan = ClanManager.clans.find(func(clan): return clan.uuid == ClanManager.current_clan_id)
	if current_clan == null:
		print("Erreur : Aucun clan sélectionné. UUID :", ClanManager.current_clan_id)
		print("UUID disponibles :")
		for clan in ClanManager.clans:
			print(" - ", clan.uuid)
		return

	# Initialiser les unités
	print("Initialisation des unités...")
	initialize_units()

func _on_ui_ready():
	"""
	Callback appelé lorsque l'UI raciale est prête.
	"""
	print("Signal reçu : l'UI raciale est prête.")
	var current_clan = ClanManager.clans.find(func(clan): return clan.uuid == ClanManager.current_clan_id)

	# Identifier l'unité leader
	var leader_unit = player_units.get_children().find(func(unit):
		return unit is BaseUnit and unit.player_id == player_id and unit.stats.unit_name == "Leader"
	)

	# Mettre à jour l'interface raciale
	if leader_unit and racial_ui and current_clan:
		racial_ui.update_leader_data(leader_unit, 3000)  # Passer le score des ressources
		print("Leader trouvé :", leader_unit.name)
	else:
		print("Erreur : Leader ou clan introuvable.")

func initialize_units():
	"""
	Initialise les unités pour le joueur, l'IA, et les entités sauvages.
	"""
	print("Détection des entités...")

	print("PlayerUnits enfants :")
	for unit in player_units.get_children():
		print(" - ", unit.name)
		if unit is BaseUnit:
			unit.set_player_id(player_id)

	print("AIUnits enfants :")
	for unit in ai_units.get_children():
		print(" - ", unit.name)
		if unit is BaseUnit:
			unit.set_player_id("AI")

	print("WildUnits enfants :")
	for unit in wild_units.get_children():
		print(" - ", unit.name)
		if unit is BaseUnit:
			unit.set_player_id("Wild")

	# Résumé des entités initialisées
	print("Résumé des entités :")
	print("- Joueur :", player_units.get_child_count())
	print("- IA :", ai_units.get_child_count())
	print("- Sauvages :", wild_units.get_child_count())
