extends CanvasLayer
class_name UIManager

#
# ================== PROPRIÉTÉS ==================
#

var race_uis = {
	"ShamaLi": preload("res://ShamaLi/Scenes/UI.tscn")
}

var race_cursors = {
	"ShamaLi": preload("res://ShamaLi/Assets/UI/cursor.png")
}

var current_ui_instance: Node = null
var unit_instance: BaseUnit = null

@onready var ui_container = $UIContainer

#
# ================== FONCTIONS VIE DU NŒUD ==================
#

func _ready():
	if not ui_container:
		print("Erreur : `UIContainer` est introuvable. Vérifiez la structure de la scène.")
	else:
		print("`UIContainer` trouvé :", ui_container)

	test_ui_manager_scene()

#
# ================== RÉCEPTION DES SIGNAUX ==================
#

func _on_selection_updated(selected_entities: Array):
	var nb = selected_entities.size()
	print("UIManager - Mise à jour de la sélection :", nb, "entité(s).")

	match nb:
		0:
			clear_ui()
		1:
			var data = selected_entities[0]
			if not (data.has("unit") and data.has("type")):
				print("Erreur : sélection invalide, manque 'unit' ou 'type'.")
				clear_ui()
				return

			unit_instance = data["unit"] as BaseUnit
			var utype = data["type"] as String
			var faction_name = data.get("faction", "Unknown")

			if current_ui_instance:
				match utype:
					"ally", "enemy", "wild":
						# Peu importe le type, on appelle la même méthode
						if current_ui_instance.has_method("update_unit_info"):
							current_ui_instance.update_unit_info(unit_instance)
			else:
				print("Aucune UI courante pour afficher l'unité.")

		_:
			var baseunits: Array = []
			for d in selected_entities:
				if d.has("unit"):
					baseunits.append(d["unit"])

			if current_ui_instance and current_ui_instance.has_method("update_multiple_units_info"):
				current_ui_instance.update_multiple_units_info(baseunits)

func _on_hovered_unit_changed(unit: BaseUnit):
	print("UIManager - Unité survolée :", unit)
	if unit:
		update_help_panel_for_unit(unit)
	else:
		clear_help_panel()

#
# ================== GESTION DES "RACES" (UI & CURSEURS) ==================
#

func set_race(race_name: String):
	var normalized_race_name = race_name.replace("'", "")
	print("Tentative de définir la race :", normalized_race_name)

	if not ui_container:
		print("Erreur : ui_container est null dans set_race. On retente plus tard.")
		call_deferred("set_race", normalized_race_name)
		return

	if normalized_race_name in race_uis:
		change_ui(normalized_race_name)
		change_cursor(normalized_race_name)
	else:
		print("Erreur : Aucun UI défini pour la race :", normalized_race_name)

func change_ui(race_name: String):
	if not ui_container:
		print("Erreur : ui_container est null avant de changer l'UI.")
		return

	if current_ui_instance:
		ui_container.remove_child(current_ui_instance)
		current_ui_instance.queue_free()
		current_ui_instance = null

	if race_name in race_uis:
		var ui_scene = race_uis[race_name].instantiate()
		ui_container.add_child(ui_scene)
		current_ui_instance = ui_scene

		# Si on avait déjà une unité sélectionnée
		if unit_instance and current_ui_instance.has_method("update_unit_info"):
			current_ui_instance.update_unit_info(unit_instance)

		print("UI pour la race", race_name, "chargée.")
	else:
		print("Race inconnue :", race_name)

func change_cursor(race_name: String):
	if race_name in race_cursors:
		var cursor_texture = race_cursors[race_name]
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur pour la race", race_name, "défini.")
	else:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW, Vector2.ZERO)
		print("Curseur par défaut rétabli.")

#
# ================== MISE À JOUR / RÉINITIALISATION DE L’UI ==================
#

func update_help_panel_for_unit(unit: BaseUnit):
	# Vérifie qu'on a bien une UI en cours
	if not current_ui_instance:
		return
	# Vérifie que la méthode existe dans l'UI courante
	if not current_ui_instance.has_method("update_help_panel"):
		return

	# ICI on ignore la logique "ennemi/allié/sauvage" et on affiche DIRECTEMENT le nom
	var help_text = unit.stats.unit_name
	current_ui_instance.update_help_panel(help_text)

func clear_help_panel():
	if current_ui_instance and current_ui_instance.has_method("clear_help_panel"):
		current_ui_instance.clear_help_panel()

func clear_ui():
	unit_instance = null

	if current_ui_instance and current_ui_instance.has_method("clear_ui"):
		current_ui_instance.clear_ui()

#
# ================== AUTRES FONCTIONS UTILES ==================
#

func update_unit_info(unit: BaseUnit):
	unit_instance = unit
	if current_ui_instance and current_ui_instance.has_method("update_unit_info"):
		current_ui_instance.update_unit_info(unit)

func update_multiple_units_info(units: Array):
	if current_ui_instance and current_ui_instance.has_method("update_multiple_units_info"):
		current_ui_instance.update_multiple_units_info(units)

func test_ui_manager_scene():
	var ui_manager_scene = preload("res://Global/Managers/UIManager.tscn")
	var instance = ui_manager_scene.instantiate()

	if instance.get_node_or_null("UIContainer"):
		print("Test réussi : UIContainer trouvé dans la scène UIManager.")
	else:
		print("Test échoué : UIContainer introuvable dans la scène UIManager.")
