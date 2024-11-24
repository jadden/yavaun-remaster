class_name GlobalMap
extends Node

@onready var unit_selection_manager: SelectionManager = null
@onready var units_container: Node = null
@export var current_map_container: Node = null
@export var race_ui_container: Node = null

func _ready():
	"""
	Prépare les nœuds et configure la scène au démarrage.
	"""
	ensure_nodes_ready()
	set_default_cursor()

func ensure_nodes_ready():
	"""
	Vérifie et initialise les nœuds essentiels.
	"""
	if not current_map_container:
		print("CurrentMap introuvable, création d'un nouveau nœud.")
		current_map_container = Node2D.new()
		current_map_container.name = "CurrentMap"
		add_child(current_map_container)

	if not race_ui_container:
		print("RaceSpecificUI introuvable, création d'un nouveau nœud.")
		race_ui_container = Node.new()
		race_ui_container.name = "RaceSpecificUI"
		add_child(race_ui_container)

	unit_selection_manager = get_node_or_null("UI/UnitSelectionManager")
	if not unit_selection_manager:
		print("UnitSelectionManager introuvable, création dynamique.")
		unit_selection_manager = SelectionManager.new()
		unit_selection_manager.name = "UnitSelectionManager"
		add_child(unit_selection_manager)

	# Retarder l'initialisation du conteneur des unités
	call_deferred("_initialize_units_container")

func _initialize_units_container():
	"""
	Initialise les références pour les entités sur la carte.
	"""
	if current_map_container:
		units_container = current_map_container.get_node_or_null("Map/EntitiesContainer")
		if not units_container:
			print("Erreur : EntitiesContainer introuvable dans CurrentMap.")
		else:
			print("EntitiesContainer trouvé :", units_container.name)
			if unit_selection_manager and unit_selection_manager is SelectionManager:
				unit_selection_manager.initialize(units_container)
	else:
		print("Erreur : CurrentMap introuvable au moment de l'initialisation.")

func load_map(map_path: String, race: String):
	"""
	Charge une nouvelle carte et configure l'interface.
	"""
	clean_previous_scene()
	print("Chargement de la carte :", map_path, " pour la race :", race)

	# Vérifier la validité des nœuds
	if not current_map_container or not unit_selection_manager or not race_ui_container:
		print("Erreur : Des nœuds nécessaires ne sont pas valides.")
		return

	# Effacer les enfants actuels dans CurrentMap
	free_children(current_map_container)

	# Charger et ajouter la nouvelle carte
	var map_scene = load(map_path)
	if not map_scene:
		print("Erreur : Impossible de charger la scène :", map_path)
		return

	var map_instance = map_scene.instantiate()
	current_map_container.add_child(map_instance)

	# Initialiser UnitSelectionManager avec les unités
	units_container = map_instance.get_node_or_null("EntitiesContainer")
	if units_container:
		unit_selection_manager.initialize(units_container)
	else:
		print("Erreur : Conteneur d'unités introuvable dans la carte :", map_path)

	# Effacer les enfants actuels dans RaceSpecificUI
	free_children(race_ui_container)

	# Charger l'UI spécifique via ThemeManager
	ThemeManager.apply_race_ui(race, race_ui_container)

	# Configurer le curseur par défaut
	set_default_cursor()

func free_children(node: Node):
	"""
	Supprime tous les enfants d'un nœud donné.
	"""
	for child in node.get_children():
		child.queue_free()

func clean_previous_scene():
	"""
	Nettoie les éléments non nécessaires de la scène actuelle.
	"""
	var root = get_tree().root
	var singleton_names = ["MusicManager", "SoundManager", "PlayerData", "GameData", "ThemeManager"]
	for child in root.get_children():
		if child != self and child.name not in singleton_names:
			print("Suppression du nœud :", child.name)
			child.queue_free()

func set_default_cursor():
	"""
	Configure le curseur par défaut.
	"""
	var default_cursor_path = "res://Assets/UI/Cursors/select_1.png"
	var default_cursor = load(default_cursor_path)
	if default_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(default_cursor)
		print("Curseur par défaut défini :", default_cursor_path)
	else:
		print("Erreur : Impossible de charger le curseur :", default_cursor_path)
