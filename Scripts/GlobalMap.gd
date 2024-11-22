class_name GlobalMap
extends Node

@onready var unit_selection_manager: Control = $UI/UnitSelectionManager
@onready var units_container: Node = $GlobalMap/CurrentMap/Map/UnitsContainer 

@export var current_map_container: Node
@export var race_ui_container: Node

func _ready():
	# Initialiser les nœuds si manquants
	if not unit_selection_manager:
		print("Erreur : UnitSelectionManager introuvable ! Création dynamique.")
		unit_selection_manager = Node.new()
		unit_selection_manager.name = "UnitSelectionManager"
		add_child(unit_selection_manager)

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

func load_map(map_path: String, race: String):
	clean_previous_scene()  # Nettoyer les éléments précédents
	print("Chargement de la carte :", map_path, " pour la race :", race)

	# Vérifier la validité des nœuds
	if not current_map_container:
		print("Erreur : current_map_container non valide.")
		return
	if not unit_selection_manager:
		print("Erreur : unit_selection_manager non valide.")
		return
	if not race_ui_container:
		print("Erreur : race_ui_container non valide.")
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
	var units_container = map_instance.get_node("UnitsContainer")
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

# Fonction utilitaire pour libérer tous les enfants d'un nœud
func free_children(node: Node):
	for child in node.get_children():
		child.queue_free()

# Fonction utilitaire pour nettoyer une scène
func clean_previous_scene():
	var root = get_tree().root
	# Liste blanche des singletons à préserver
	var singleton_names = ["MusicManager", "SoundManager", "PlayerData", "GameData", "ThemeManager"]
	
	for child in root.get_children():
		if child != self and child.name not in singleton_names:
			print("Suppression du nœud :", child.name)
			child.queue_free()


# Fonction pour définir le curseur par défaut sur la carte
func set_default_cursor():
	var default_cursor_path = "res://Assets/UI/Cursors/select_1.png"
	var default_cursor = load(default_cursor_path)
	if default_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Assure que le curseur est visible
		Input.set_custom_mouse_cursor(default_cursor)
		print("Curseur par défaut défini :", default_cursor_path)
	else:
		print("Erreur : Impossible de charger le curseur :", default_cursor_path)
