extends Control
class_name SelectionManager

# Gestion des entités
var units: Array = []  # Liste des unités
var buildings: Array = []  # Liste des bâtiments
var selected_entities: Array = []  # Liste des entités sélectionnées

# Gestion de la sélection
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
var is_selecting: bool = false

# Références aux nœuds
@onready var selection_rectangle: Control = $SelectionRectangle
@onready var rectangle_panel: Panel = $SelectionRectangle/Rectangle
var ui: Node = null

func _ready():
	"""
	Initialise le gestionnaire de sélection.
	"""
	if selection_rectangle and rectangle_panel:
		selection_rectangle.visible = false
		print("SelectionManager prêt. Rectangle de sélection masqué.")
	else:
		print("Erreur : Les nœuds `SelectionRectangle` ou `Rectangle` sont manquants.")

func set_ui(ui_instance: Node):
	"""
	Associe une instance de l'UI raciale.
	"""
	ui = ui_instance
	if ui:
		print("UI correctement associée :", ui.name)
	else:
		print("Erreur : Impossible d'associer l'UI.")

func initialize(entities_container: Node):
	"""
	Initialise les entités à partir d'un conteneur parent.
	"""
	units.clear()
	buildings.clear()
	selected_entities.clear()

	print("Initialisation des entités depuis :", entities_container.name)
	gather_entities_recursive(entities_container)

	print("Entités initialisées :", units.size(), "unités et", buildings.size(), "bâtiments.")

func gather_entities_recursive(container: Node):
	"""
	Collecte récursivement les entités dans un conteneur et ses enfants.
	"""
	for child in container.get_children():
		if child is BaseUnit:
			print("Unité détectée :", child.name)
			child.set_selected(false)
			units.append(child)
		elif child is BaseBuilding:
			print("Bâtiment détecté :", child.name)
			child.set_selected(false)
			buildings.append(child)
		elif child is Node:  # Vérifie les sous-conteneurs
			gather_entities_recursive(child)

func _input(event: InputEvent):
	"""
	Gère les événements utilisateur.
	"""
	print("Input détecté :", event)
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion and is_selecting:
		update_selection(event.position)

func _handle_mouse_button_input(event: InputEventMouseButton):
	"""
	Gère les clics pour démarrer ou terminer la sélection.
	"""
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_selection(event.position)
		else:
			end_selection()
	elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		clear_selection()

func start_selection(start_pos: Vector2):
	"""
	Démarre une sélection.
	"""
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	selection_rectangle.visible = true
	update_selection_rectangle()
	print("Début de sélection à :", selection_start)

func update_selection(end_pos: Vector2):
	"""
	Met à jour le rectangle de sélection.
	"""
	selection_end = end_pos
	update_selection_rectangle()

func end_selection():
	"""
	Termine la sélection et met à jour les entités sélectionnées.
	"""
	is_selecting = false
	selection_rectangle.visible = false

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()
	print("Rectangle de sélection :", selection_rect)
	selected_entities.clear()

	for entity in units + buildings:
		print("Vérification pour :", entity.name, "à la position :", entity.global_position)
		if selection_rect.has_point(entity.global_position):
			print("-> Dans le rectangle :", entity.name)
			entity.set_selected(true)
			selected_entities.append(entity)
		else:
			entity.set_selected(false)

	print("Sélection terminée. Entités sélectionnées :", selected_entities)
	update_ui()

func clear_selection():
	"""
	Désélectionne toutes les entités.
	"""
	for entity in selected_entities:
		entity.set_selected(false)
	selected_entities.clear()

	if ui and ui.has_method("clear_ui"):
		ui.call("clear_ui")
	print("Sélection effacée.")

func update_ui():
	"""
	Mise à jour de l'UI en fonction des entités sélectionnées.
	"""
	if not ui:
		print("Erreur : UI non initialisée.")
		return

	if selected_entities.size() == 1:
		ui.call("update_unit_info", selected_entities[0])
	elif selected_entities.size() > 1:
		ui.call("update_multiple_units_info", selected_entities)
	else:
		ui.call("clear_ui")

func update_selection_rectangle():
	"""
	Met à jour les dimensions et la position du rectangle de sélection.
	"""
	var top_left = selection_start
	var rect_size = selection_end - selection_start

	if rect_size.x < 0:
		top_left.x += rect_size.x
		rect_size.x = -rect_size.x
	if rect_size.y < 0:
		top_left.y += rect_size.y
		rect_size.y = -rect_size.y

	rectangle_panel.position = top_left
	rectangle_panel.size = rect_size
	print("Rectangle mis à jour : position =", top_left, ", taille =", rect_size)
