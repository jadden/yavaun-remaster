extends CanvasLayer
class_name UIManager

# Dictionnaire pour stocker les références aux UI des races
var race_uis = {
	#"Eaggra": preload("res://UI/Races/EaggraUI.tscn"),
	#"Obblinox": preload("res://UI/Races/ObblinoxUI.tscn"),
	"ShamaLi": preload("res://ShamaLi/Scenes/UI.tscn"),
	#"ThaRoon": preload("res://UI/Races/ThaRoonUI.tscn")
}

# Dictionnaire pour stocker les curseurs des races
var race_cursors = {
	"Eaggra": preload("res://Eaggra/Assets/UI/cursor.png"),
	"Obblinox": preload("res://Obblinox/Assets/UI/cursor.png"),
	"ShamaLi": preload("res://ShamaLi/Assets/UI/cursor.png"),
	"ThaRoon": preload("res://ThaRoon/Assets/UI/cursor.png")
}

# Instance courante de l'UI affichée
var current_ui_instance = null

# Référence à l'élément UIContainer
@onready var ui_container = $UIContainer

# Référence à l'unité à afficher (pour une seule unité)
var unit_instance = null

func _ready():
	pass

# Fonction pour changer l'UI et le curseur en fonction de la race
func set_race(race_name):
	print("Tentative de définir la race :", race_name)
	# Changer l'UI
	change_ui(race_name)
	# Changer le curseur
	change_cursor(race_name)

func change_ui(race_name):
	# Supprimer l'UI actuelle si elle existe
	if current_ui_instance:
		ui_container.remove_child(current_ui_instance)
		current_ui_instance.queue_free()
		current_ui_instance = null
	
	# Charger et ajouter la nouvelle UI si la race est reconnue
	if race_name in race_uis:
		var ui_scene = race_uis[race_name].instance()
		ui_container.add_child(ui_scene)
		current_ui_instance = ui_scene
		# Mettre à jour les éléments UI avec les données de l'unité
		if ui_scene.has_method("update_unit_info"):
			ui_scene.update_unit_info(unit_instance)
		print("UI pour la race", race_name, "chargée.")
	else:
		print("Race inconnue :", race_name)

func change_cursor(race_name):
	if race_name in race_cursors:
		var cursor_texture = race_cursors[race_name]
		# Définir le curseur personnalisé avec une forme spécifique si nécessaire
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur pour la race", race_name, "défini.")
	else:
		# Réinitialiser le curseur par défaut
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur par défaut rétabli.")

# Délégation des mises à jour d'UI
func update_unit_info(unit: BaseUnit):
	if current_ui_instance and current_ui_instance.has_method("update_unit_info"):
		current_ui_instance.update_unit_info(unit)

func update_building_info(building: BaseBuilding):
	if current_ui_instance and current_ui_instance.has_method("update_building_info"):
		current_ui_instance.update_building_info(building)

func clear_ui():
	if current_ui_instance and current_ui_instance.has_method("clear_ui"):
		current_ui_instance.clear_ui()

func update_help_panel(entity_name: String):
	"""
	Met à jour le HelpPanel avec le nom de l'entité survolée.
	"""
	if current_ui_instance and current_ui_instance.has_method("update_help_panel"):
		current_ui_instance.update_help_panel(entity_name)

func clear_help_panel():
	"""
	Réinitialise le HelpPanel en le cachant.
	"""
	if current_ui_instance and current_ui_instance.has_method("clear_help_panel"):
		current_ui_instance.clear_help_panel()
