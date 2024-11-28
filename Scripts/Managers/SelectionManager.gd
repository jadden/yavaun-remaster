extends Control
class_name SelectionManager

# Gestion des entités
var units: Array = []
var buildings: Array = []
var selected_entities: Array = []

# Gestion de la sélection
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
var is_selecting: bool = false

# Références aux nœuds
@onready var selection_rectangle: Control = $SelectionRectangle  # Le conteneur principal
@onready var rectangle_panel: Panel = $SelectionRectangle/Rectangle  # Le rectangle visible
var ui: Node = null  # Référence à l'UI raciale

func _ready():
	"""
	Initialise le `SelectionManager` et masque le rectangle.
	"""
	if selection_rectangle and rectangle_panel:
		selection_rectangle.visible = false
		rectangle_panel.visible = true
		print("SelectionManager prêt. Rectangle de sélection masqué.")
	else:
		print("Erreur : Les nœuds de sélection ne sont pas configurés correctement.")

func set_ui(ui_instance: Node):
	"""
	Associe dynamiquement une instance de l'UI raciale.
	"""
	ui = ui_instance
	if ui:
		print("UI correctement associée :", ui.name)
	else:
		print("Erreur : Impossible d'associer l'UI.")

func initialize(entities_container: Node):
	"""
	Initialise les entités à partir d'un conteneur.
	"""
	units.clear()
	buildings.clear()
	selected_entities.clear()

	for entity in entities_container.get_children():
		if entity is BaseUnit:
			entity.set_selected(false)  # Assurez-vous que chaque unité désactive son `SelectionBox`
			units.append(entity)
		elif entity is BaseBuilding:
			entity.set_selected(false)
			buildings.append(entity)

	print("Entités initialisées :", units.size(), " unités et ", buildings.size(), " bâtiments.")

func _input(event: InputEvent):
	"""
	Gère les événements d'entrée utilisateur.
	"""
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion and is_selecting:
		update_selection(event.position)

func _handle_mouse_button_input(event: InputEventMouseButton):
	"""
	Gère les clics de souris pour démarrer ou terminer la sélection.
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
	Démarre le rectangle de sélection.
	"""
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	if selection_rectangle:
		selection_rectangle.visible = true
	update_selection_rectangle()
	print("Début de sélection à :", selection_start)

func update_selection(end_pos: Vector2):
	"""
	Mise à jour de la sélection en fonction de la position de la souris.
	"""
	selection_end = end_pos
	update_selection_rectangle()

func end_selection():
	"""
	Termine la sélection et met à jour les entités sélectionnées.
	"""
	is_selecting = false
	if selection_rectangle:
		selection_rectangle.visible = false

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()
	selected_entities.clear()

	# Parcourt les entités pour identifier celles sélectionnées
	for entity in units + buildings:
		if selection_rect.has_point(entity.global_position):
			entity.set_selected(true)  # Active le `SelectionBox`
			selected_entities.append(entity)
		else:
			entity.set_selected(false)

	print("Sélection terminée. Entités sélectionnées :", selected_entities)
	update_ui()

func clear_selection():
	"""
	Réinitialise la sélection.
	"""
	for entity in selected_entities:
		entity.set_selected(false)
	selected_entities.clear()

	if ui and ui.has_method("clear_ui"):
		ui.call("clear_ui")
	print("Sélection effacée.")

func update_ui():
	"""
	Mise à jour de l'UI raciale en fonction de la sélection.
	"""
	if not ui:
		print("Erreur : UI raciale non initialisée.")
		return
	if selected_entities.size() == 1:
		ui.call("update_unit_info", selected_entities[0])
	elif selected_entities.size() > 1:
		ui.call("update_multiple_units_info", selected_entities)
	else:
		ui.call("clear_ui")

func update_selection_rectangle():
	"""
	Met à jour la position et les dimensions du rectangle de sélection.
	"""
	var top_left = selection_start
	var rect_size = selection_end - selection_start

	if rect_size.x < 0:
		top_left.x += rect_size.x
		rect_size.x = -rect_size.x
	if rect_size.y < 0:
		top_left.y += rect_size.y
		rect_size.y = -rect_size.y

	if rectangle_panel:  # Assurez-vous que `rectangle_panel` est bien configuré
		rectangle_panel.position = top_left
		rectangle_panel.size = rect_size
	print("Rectangle de sélection mis à jour : position =", top_left, ", taille =", rect_size)
