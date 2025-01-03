extends CanvasLayer
class_name UIManager

# Référence au `SelectionManager`
var selection_manager: SelectionManager = null

# Dictionnaire pour stocker les références aux UI des races
var race_uis = {
	"ShamaLi": preload("res://ShamaLi/Scenes/UI.tscn")
}

# Dictionnaire pour stocker les curseurs des races
var race_cursors = {
	"ShamaLi": preload("res://ShamaLi/Assets/UI/cursor.png"),
}

# Instance courante de l'UI affichée
var current_ui_instance = null

# Référence à l'unité à afficher
var unit_instance: BaseUnit = null

# Référence à l'élément UIContainer
@onready var ui_container = $UIContainer

func _ready():
	# Vérifiez que le `SelectionManager` est disponible et connectez les signaux
	if not ui_container:
		print("Erreur : `UIContainer` est introuvable. Vérifiez la structure de la scène.")
		return
	else:
		print("`UIContainer` est trouvé.")

	if selection_manager:
		selection_manager.connect("selection_updated", Callable(self, "_on_selection_updated"))
		selection_manager.connect("hovered_unit_changed", Callable(self, "_on_hovered_unit_changed"))
	else:
		print("Erreur : SelectionManager non défini dans UIManager.")
		
	test_ui_manager_scene()

func _on_selection_updated(selected_entities: Array):
	print("UIManager - Mise à jour de la sélection :", selected_entities.size(), "entités sélectionnées.")
	if selected_entities.size() == 1:
		var unit = selected_entities[0]
		if unit is BaseUnit:
			update_unit_info(unit)
	elif selected_entities.size() > 1:
		var units = []
		for entity in selected_entities:
			if entity is BaseUnit:
				units.append(entity)
		update_multiple_units_info(units)
	else:
		clear_ui()

func _on_hovered_unit_changed(unit: BaseUnit):
	print("UIManager - Unité survolée :", unit)
	if unit:
		update_help_panel(unit.name)
	else:
		clear_help_panel()

# Fonction pour changer l'UI et le curseur en fonction de la race
func set_race(race_name):
	var normalized_race_name = race_name.replace("'", "")
	if not ui_container:
		print("Erreur : ui_container est null dans set_race. Report de l'appel.")
		call_deferred("set_race", normalized_race_name)
		return
	print("Tentative de définir la race :", normalized_race_name)
	if normalized_race_name in race_uis:
		change_ui(normalized_race_name)
		change_cursor(normalized_race_name)
	else:
		print("Erreur : Aucun UI défini pour la race :", normalized_race_name)

func change_ui(race_name):
	print("UIContainer actuel :", ui_container)
	if not ui_container:
		print("Erreur : ui_container est null avant de changer l'UI.")
		return

	# Supprimer l'UI actuelle si elle existe
	if current_ui_instance:
		ui_container.remove_child(current_ui_instance)
		current_ui_instance.queue_free()
		current_ui_instance = null

	# Charger et ajouter la nouvelle UI si la race est reconnue
	if race_name in race_uis:
		var ui_scene = race_uis[race_name].instantiate()  # Utilisez `instantiate()`
		ui_container.add_child(ui_scene)
		current_ui_instance = ui_scene
		# Mettre à jour les éléments UI avec les données de l'unité
		if unit_instance and ui_scene.has_method("update_unit_info"):
			ui_scene.update_unit_info(unit_instance)
		print("UI pour la race", race_name, "chargée.")
	else:
		print("Race inconnue :", race_name)

func change_cursor(race_name):
	if race_name in race_cursors:
		var cursor_texture = race_cursors[race_name]
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur pour la race", race_name, "défini.")
	else:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur par défaut rétabli.")

# Délégation des mises à jour d'UI
func update_unit_info(unit: BaseUnit):
	unit_instance = unit  # Enregistrer l'unité sélectionnée
	if current_ui_instance and current_ui_instance.has_method("update_unit_info"):
		current_ui_instance.update_unit_info(unit)

func update_multiple_units_info(units: Array):
	if current_ui_instance and current_ui_instance.has_method("update_multiple_units_info"):
		current_ui_instance.update_multiple_units_info(units)

func update_help_panel(entity_name: String):
	if current_ui_instance and current_ui_instance.has_method("update_help_panel"):
		current_ui_instance.update_help_panel(entity_name)

func clear_help_panel():
	if current_ui_instance and current_ui_instance.has_method("clear_help_panel"):
		current_ui_instance.clear_help_panel()

func clear_ui():
	if current_ui_instance and current_ui_instance.has_method("clear_ui"):
		current_ui_instance.clear_ui()
		
func test_ui_manager_scene():
	var ui_manager_scene = preload("res://Global/Managers/UIManager.tscn")
	var instance = ui_manager_scene.instantiate()

	if instance.get_node_or_null("UIContainer"):
		print("Test réussi : UIContainer trouvé dans la scène UIManager.")
	else:
		print("Test échoué : UIContainer introuvable dans la scène UIManager.")
