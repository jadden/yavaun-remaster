extends CanvasLayer
class_name UIManager

#
# ================== PROPRIÉTÉS ==================
#

# 1) Référence au `SelectionManager` (connecté depuis l’extérieur OU trouvé via code)
var selection_manager: SelectionManager = null

# 2) Dictionnaire pour stocker les références aux UI des différentes “races”
var race_uis = {
	"ShamaLi": preload("res://ShamaLi/Scenes/UI.tscn")
}

# 3) Dictionnaire pour stocker les curseurs des “races”
var race_cursors = {
	"ShamaLi": preload("res://ShamaLi/Assets/UI/cursor.png")
}

# 4) Instance courante de l'UI chargée (ex: la scène UI ShamaLi)
var current_ui_instance: Node = null

# 5) On mémorise l’unité sélectionnée si on veut la reprendre en cas de changement d’UI
var unit_instance: BaseUnit = null

# 6) Conteneur (Control/Node) dans lequel on instancie l’UI correspondante
@onready var ui_container = $UIContainer

#
# ================== FONCTIONS VIE DU NŒUD ==================
#

func _ready():
	# Vérifie qu’on a bien le conteneur UI
	if not ui_container:
		print("Erreur : `UIContainer` est introuvable. Vérifiez la structure de la scène.")
	else:
		print("`UIContainer` trouvé :", ui_container)

	# Si le selection_manager n’est pas déjà assigné (dans l’éditeur), on tente de le configurer plus tard
	if not selection_manager:
		print("UIManager: 'selection_manager' est null, on va tenter de le récupérer plus tard.")
		call_deferred("_try_connect_selection_manager")
	else:
		# S’il est déjà défini, on connecte les signaux immédiatement
		print("UIManager: 'selection_manager' trouvé dans l'éditeur, on connecte les signaux.")
		_connect_selection_manager_signals()

	# Vérifie la scène UIManager.tscn (optionnel)
	test_ui_manager_scene()

#
# ================== MÉTHODES DE CONFIG DU SELECTION_MANAGER ==================
#

func _try_connect_selection_manager():
	if not selection_manager:
		# Par exemple, on tente de le récupérer via un chemin global (si c’est un autoload / singleton)
		print("UIManager: Tentative de récupération du selection_manager dans l'arbre.")
		var found_manager = get_node_or_null("/root/SelectionManager")
		if found_manager:
			selection_manager = found_manager
			print("UIManager: selection_manager trouvé via /root/SelectionManager.")
		else:
			print("UIManager: Impossible de trouver selection_manager dans /root/SelectionManager.")

	# Maintenant, si on l’a (ou si on l’avait déjà), on connecte
	if selection_manager:
		_connect_selection_manager_signals()
	else:
		print("UIManager: selection_manager est toujours null après deferred.")

func _connect_selection_manager_signals():
	# On connecte les signaux dont on a besoin
	selection_manager.connect("selection_updated", Callable(self, "_on_selection_updated"))
	selection_manager.connect("hovered_unit_changed", Callable(self, "_on_hovered_unit_changed"))
	print("UIManager: Connecté aux signaux de selection_manager avec succès.")

#
# ================== RÉCEPTION DES SIGNAUX ==================
#

func _on_selection_updated(selected_entities: Array):
	var nb = selected_entities.size()
	print("UIManager - Mise à jour de la sélection :", nb, "entité(s).")

	match nb:
		0:
			# Aucune unité sélectionnée : on nettoie l’UI
			clear_ui()

		1:
			# Une seule unité : on récupère le dictionnaire
			var data = selected_entities[0]
			if not (data.has("unit") and data.has("type")):
				print("Erreur : sélection invalide, manque 'unit' ou 'type'.")
				clear_ui()
				return

			var unit = data["unit"] as BaseUnit
			var utype = data["type"] as String
			var faction_name = data.get("faction", "Unknown")

			# On garde en mémoire l'unité sélectionnée
			unit_instance = unit

			# On met à jour l'UI si elle existe
			if current_ui_instance:
				match utype:
					"ally":
						if current_ui_instance.has_method("update_unit_info"):
							current_ui_instance.update_unit_info(unit)
						else:
							print("L'UI courante n'a pas 'update_unit_info'.")
					"enemy":
						if current_ui_instance.has_method("update_generic_enemy_info"):
							current_ui_instance.update_generic_enemy_info(faction_name)
						else:
							print("L'UI courante n'a pas 'update_generic_enemy_info'.")
					"wild":
							current_ui_instance.update_generic_wild_info(unit, default_wild_portrait)
						else:
							print("L'UI courante n'a pas 'update_generic_wild_info'.")
					_:
						print("Type d'unité inconnu :", utype)
			else:
				print("Aucune UI courante pour afficher l'unité.")

		_:
			# Plusieurs unités : on construit un tableau de BaseUnit
			var baseunits: Array = []
			for d in selected_entities:
				if d.has("unit"):
					baseunits.append(d["unit"])

			if current_ui_instance and current_ui_instance.has_method("update_multiple_units_info"):
				current_ui_instance.update_multiple_units_info(baseunits)
			else:
				print("L'UI courante n'a pas 'update_multiple_units_info'.")

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

	# On enlève l'UI précédente si besoin
	if current_ui_instance:
		ui_container.remove_child(current_ui_instance)
		current_ui_instance.queue_free()
		current_ui_instance = null

	# On instancie la nouvelle UI
	if race_name in race_uis:
		var ui_scene = race_uis[race_name].instantiate()
		ui_container.add_child(ui_scene)
		current_ui_instance = ui_scene

		# Si on avait déjà une unité sélectionnée, on met à jour l'UI
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
	# Vérifie qu'on a bien un selection_manager pour accéder aux unités ennemies
	if not selection_manager:
		print("Erreur : selection_manager est null; on ne peut pas vérifier enemy_units.")
		return

	# Vérifie que la méthode existe dans l'UI courante
	if not current_ui_instance.has_method("update_help_panel"):
		return

	var help_text = ""

	# ----- LOGIQUE SPÉCIFIQUE -----
	# Si l’unité est ennemie (présente dans selection_manager.enemy_units)
	if unit in selection_manager.enemy_units:
		# On affiche juste le nom de la race (faction)
		if unit.stats and unit.stats.faction != "":
			help_text = unit.stats.faction
		else:
			help_text = "Inconnu"
	else:
		# Unité sous notre contrôle OU unité sauvage
		if unit.stats:
			if unit.stats.help_text and unit.stats.help_text != "":
				help_text = unit.stats.help_text
			else:
				help_text = unit.stats.unit_name
		else:
			help_text = "Aucune information disponible."
	# ----- FIN DE LA LOGIQUE SPÉCIFIQUE -----

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
