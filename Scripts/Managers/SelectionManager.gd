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
@onready var selection_rectangle: Control = $SelectionRectangle
@onready var rectangle_panel: Panel = $SelectionRectangle/Rectangle

func _ready():
	"""
	Initialise les références et masque le rectangle au démarrage.
	"""
	selection_rectangle.visible = false
	print("SelectionManager prêt. Rectangle masqué.")

func initialize(entities_container: Node):
	"""
	Initialise les unités et bâtiments à partir d'un conteneur donné.
	"""
	units.clear()
	buildings.clear()
	selected_entities.clear()

	for entity in entities_container.get_children():
		if entity is BaseUnit:
			entity.set_selected(false)
			units.append(entity)
		elif entity is BaseBuilding:
			entity.set_selected(false)
			buildings.append(entity)
		else:
			print("Entité inconnue détectée :", entity.name)

	print("Entités initialisées : ", units.size(), " unités et ", buildings.size(), " bâtiments.")

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
	Gère les clics de souris pour débuter ou terminer la sélection.
	"""
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_selection(event.position)
		else:
			end_selection()

func start_selection(start_pos: Vector2):
	"""
	Commence la sélection avec le rectangle.
	"""
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	selection_rectangle.visible = true
	update_selection_rectangle()
	print("Début de sélection : position de départ :", selection_start)

func update_selection(end_pos: Vector2):
	"""
	Met à jour les dimensions et la position du rectangle.
	"""
	selection_end = end_pos
	update_selection_rectangle()

func end_selection():
	"""
	Termine la sélection et applique les changements.
	"""
	is_selecting = false
	selection_rectangle.visible = false

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()
	selected_entities.clear()

	for entity in units + buildings:
		if selection_rect.has_point(entity.global_position):
			entity.set_selected(true)
			selected_entities.append(entity)
		else:
			entity.set_selected(false)

	print("Sélection terminée. Entités sélectionnées :", selected_entities)

func update_selection_rectangle():
	"""
	Met à jour la position et les dimensions du rectangle dans la scène.
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
	print("Rectangle position :", rectangle_panel.position, ", size :", rectangle_panel.size)
