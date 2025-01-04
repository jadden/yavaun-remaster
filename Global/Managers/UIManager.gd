extends CanvasLayer
class_name UIManager

##
## ================== PROPRIÉTÉS ==================
##

## Référence au `SelectionManager` (connecté depuis l’extérieur ou dans l’éditeur)
var selection_manager: SelectionManager = null

## Dictionnaire pour stocker les références aux UI des différentes “races”
var race_uis = {
	"ShamaLi": preload("res://ShamaLi/Scenes/UI.tscn")
}

## Dictionnaire pour stocker les curseurs des “races”
var race_cursors = {
	"ShamaLi": preload("res://ShamaLi/Assets/UI/cursor.png"),
}

## Instance courante de l'UI chargée (ex: la scène UI ShamaLi)
var current_ui_instance = null

## On mémorise l’unité sélectionnée si on veut la reprendre en cas de changement d’UI
var unit_instance: BaseUnit = null

## Conteneur (Control/Node) dans lequel on instancie l’UI correspondante
@onready var ui_container = $UIContainer

##
## ================== FONCTIONS VIE DU NŒUD ==================
##

func _ready():
	# Vérifie qu’on a bien le conteneur UI
	if not ui_container:
		print("Erreur : `UIContainer` est introuvable. Vérifiez la structure de la scène.")
	else:
		print("`UIContainer` trouvé :", ui_container)

	# On connecte les signaux du SelectionManager si disponible
	if selection_manager:
		selection_manager.connect("selection_updated",  Callable(self, "_on_selection_updated"))
		selection_manager.connect("hovered_unit_changed", Callable(self, "_on_hovered_unit_changed"))
	else:
		print("Erreur : `selection_manager` non défini dans UIManager.")

	# Petit test (optionnel) pour s’assurer que la scène UIManager.tscn est valide
	test_ui_manager_scene()

##
## ================== RÉCEPTION DES SIGNAUX ==================
##

##
## Réagit à la mise à jour de la sélection (clic simple, sélection rect, ou désélection).
##
func _on_selection_updated(selected_entities: Array):
	var nb = selected_entities.size()
	print("UIManager - Mise à jour de la sélection :", nb, "entité(s).")

	match nb:
		0:
			# Aucune unité : on nettoie l’UI
			clear_ui()

		1:
			# Une seule unité : on met à jour l’UI pour l’unité
			var unit = selected_entities[0]
			if unit is BaseUnit:
				update_unit_info(unit)

		_:
			# Plus d’une unité : on met à jour l’UI groupée
			var units = []
			for entity in selected_entities:
				if entity is BaseUnit:
					units.append(entity)
			update_multiple_units_info(units)

##
## Réagit lorsque le curseur survole une (nouvelle) unité 
## ou qu’on arrête de survoler (unit = null).
##
func _on_hovered_unit_changed(unit: BaseUnit):
	print("UIManager - Unité survolée :", unit)
	if unit:
		update_help_panel(unit.name)
	else:
		clear_help_panel()

##
## ================== GESTION DES "RACES" (UI & CURSEURS) ==================
##

##
## Change l’UI et le curseur en fonction de la “race” demandée.
## On sanitise la chaîne reçue si besoin.
##
func set_race(race_name: String):
	var normalized_race_name = race_name.replace("'", "")
	print("Tentative de définir la race :", normalized_race_name)

	if not ui_container:
		# Si le conteneur n’est pas encore prêt, on reporte l’appel
		print("Erreur : ui_container est null dans set_race. On retente plus tard.")
		call_deferred("set_race", normalized_race_name)
		return

	if normalized_race_name in race_uis:
		change_ui(normalized_race_name)
		change_cursor(normalized_race_name)
	else:
		print("Erreur : Aucun UI défini pour la race :", normalized_race_name)

##
## Décharge l’UI courante et charge la nouvelle scène correspondant à `race_name`.
##
func change_ui(race_name: String):
	if not ui_container:
		print("Erreur : ui_container est null avant de changer l'UI.")
		return

	# Retire l’UI actuelle si elle existe
	if current_ui_instance:
		ui_container.remove_child(current_ui_instance)
		current_ui_instance.queue_free()
		current_ui_instance = null

	# Instancie la nouvelle UI
	if race_name in race_uis:
		var ui_scene = race_uis[race_name].instantiate()
		ui_container.add_child(ui_scene)
		current_ui_instance = ui_scene

		# Si on avait déjà un unit_instance sélectionné, on appelle update_unit_info
		if unit_instance and current_ui_instance.has_method("update_unit_info"):
			current_ui_instance.update_unit_info(unit_instance)

		print("UI pour la race", race_name, "chargée.")
	else:
		print("Race inconnue :", race_name)

##
## Change le curseur par défaut pour un curseur spécifique à la race.
##
func change_cursor(race_name: String):
	if race_name in race_cursors:
		var cursor_texture = race_cursors[race_name]
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur pour la race", race_name, "défini.")
	else:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur par défaut rétabli.")


##
## ================== MISE À JOUR / RÉINITIALISATION DE L’UI ==================
##

##
## Affiche une UI pour une seule unité (ex: portrait, stats, etc.).
##
func update_unit_info(unit: BaseUnit):
	unit_instance = unit  # On mémorise l’unité courante
	if current_ui_instance and current_ui_instance.has_method("update_unit_info"):
		current_ui_instance.update_unit_info(unit)

##
## Affiche une UI adaptée pour plusieurs unités (ex: liste ou résumé).
##
func update_multiple_units_info(units: Array):
	if current_ui_instance and current_ui_instance.has_method("update_multiple_units_info"):
		current_ui_instance.update_multiple_units_info(units)

##
## Met à jour un “help panel” (texte contextuel) si l’UI le gère.
##
func update_help_panel(entity_name: String):
	if current_ui_instance and current_ui_instance.has_method("update_help_panel"):
		current_ui_instance.update_help_panel(entity_name)

##
## Efface le help panel si l’UI gère cette fonctionnalité.
##
func clear_help_panel():
	if current_ui_instance and current_ui_instance.has_method("clear_help_panel"):
		current_ui_instance.clear_help_panel()

##
## Réinitialise l’UI (pas d’entité sélectionnée).
##
func clear_ui():
	# On efface l’unité mémorisée (plus rien de sélectionné)
	unit_instance = null

	if current_ui_instance and current_ui_instance.has_method("clear_ui"):
		current_ui_instance.clear_ui()
	else:
		# Si l’UI n’a pas de clear_ui, on peut au besoin
		# la supprimer complètement, ou laisser tel quel
		pass

##
## ================== TEST D’INTÉGRITÉ ==================
##

##
## Petit test qui vérifie si 'UIManager.tscn' contient un UIContainer.
##
func test_ui_manager_scene():
	var ui_manager_scene = preload("res://Global/Managers/UIManager.tscn")
	var instance = ui_manager_scene.instantiate()

	if instance.get_node_or_null("UIContainer"):
		print("Test réussi : UIContainer trouvé dans la scène UIManager.")
	else:
		print("Test échoué : UIContainer introuvable dans la scène UIManager.")
