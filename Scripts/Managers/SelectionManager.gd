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
@onready var ui: Node = null  # Référence à l'UI raciale (ShamaLiUI)

func _ready():
	"""
	Initialise les références et masque le rectangle au démarrage.
	"""
	selection_rectangle.visible = false
	print("SelectionManager prêt. Rectangle masqué.")
	ui = get_node("/root/GlobalMap/UI/Panel")  # Mettre à jour ce chemin selon la scène
	if not ui:
		print("Erreur : UI raciale introuvable.")

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
	elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		clear_selection()

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
	update_ui()

func clear_selection():
	"""
	Désélectionne toutes les entités et met à jour l'UI.
	"""
	for entity in selected_entities:
		entity.set_selected(false)
	selected_entities.clear()

	if ui and ui.has_method("clear_ui"):
		ui.clear_ui()

func update_ui():
	"""
	Met à jour l'UI en fonction des entités sélectionnées.
	"""
	if ui:
		if selected_entities.size() == 1:
			var entity = selected_entities[0]
			if entity is BaseUnit and ui.has_method("update_unit_info"):
				ui.update_unit_info(entity)
			elif entity is BaseBuilding and ui.has_method("update_building_info"):
				ui.update_building_info(entity)
		else:
			if ui.has_method("clear_ui"):
				ui.clear_ui()

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

func _on_entity_mouse_entered(entity_name: String):
	"""
	Informe l'UI raciale que l'utilisateur survole une entité.
	"""
	if ui and ui.has_method("update_help_panel"):
		ui.update_help_panel(entity_name)

func _on_entity_mouse_exited():
	"""
	Informe l'UI raciale que l'utilisateur a cessé de survoler une entité.
	"""
	if ui and ui.has_method("clear_help_panel"):
		ui.clear_help_panel()
