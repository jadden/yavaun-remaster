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
var camera: Camera2D = null  # Référence à la caméra
var ui: Node = null  # Référence à l'interface raciale
var player_id: String = "Player1"  # ID du joueur actuel

func _ready():
	"""
	Initialise les références et cache le rectangle de sélection.
	"""
	if selection_rectangle and rectangle_panel:
		selection_rectangle.visible = false
		print("SelectionManager prêt. Rectangle de sélection masqué.")
	else:
		print("Erreur : Les nœuds `SelectionRectangle` ou `Rectangle` sont manquants.")

func set_ui(ui_instance: Node):
	"""
	Associe l'interface raciale au gestionnaire.
	"""
	ui = ui_instance
	if ui:
		print("UI correctement associée :", ui.name)
	else:
		print("Erreur : Impossible d'associer l'UI.")

func set_camera(camera_instance: Camera2D):
	"""
	Associe la caméra au gestionnaire.
	"""
	camera = camera_instance
	if camera:
		print("Caméra définie pour SelectionManager :", camera.name)
	else:
		print("Erreur : Impossible d'associer la caméra.")

func initialize(entities_container: Node):
	"""
	Initialise les entités à partir du conteneur spécifié.
	"""
	units.clear()
	buildings.clear()
	selected_entities.clear()
	gather_entities_recursive(entities_container)
	print("Entités initialisées :", units.size(), "unités et", buildings.size(), "bâtiments.")

func gather_entities_recursive(container: Node):
	"""
	Récupère les entités dans le conteneur spécifié et ses enfants.
	"""
	for child in container.get_children():
		if child is BaseUnit:
			print("BaseUnit trouvée :", child.name, "Position globale :", child.global_position)
			child.set_selected(false)
			units.append(child)
		elif child is BaseBuilding:
			print("BaseBuilding trouvée :", child.name, "Position globale :", child.global_position)
			child.set_selected(false)
			buildings.append(child)
		elif child is Node:
			gather_entities_recursive(child)

func _input(event: InputEvent):
	"""
	Gère les événements utilisateur pour la sélection.
	"""
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion and is_selecting:
		update_selection(event.position)

func _handle_mouse_button_input(event: InputEventMouseButton):
	"""
	Gère les clics pour commencer ou terminer une sélection.
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
	Démarre une sélection avec la position initiale.
	"""
	clear_selection()  # Réinitialise toutes les entités avant de commencer une nouvelle sélection
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	selection_rectangle.visible = true
	update_selection_rectangle()

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

	if camera == null:
		print("Erreur : La caméra n'est pas définie pour convertir les coordonnées.")
		return

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()
	print("Rectangle de sélection :", selection_rect)

	selected_entities.clear()

	for entity in units:
		var entity_screen_pos = camera.global_to_viewport_position(entity.global_position)
		if selection_rect.has_point(entity_screen_pos):
			if entity.player_id == player_id:
				entity.set_selected(true)
				selected_entities.append(entity)
	print("Sélection terminée. Entités sélectionnées :", selected_entities)
	update_ui()

func clear_selection():
	"""
	Désélectionne toutes les entités et vide la sélection active.
	"""
	for entity in units:
		entity.set_selected(false)
	selected_entities.clear()
	if ui and ui.has_method("reset_ui"):
		ui.call("reset_ui")

func update_ui():
	"""
	Mise à jour de l'UI en fonction des entités sélectionnées.
	"""
	if not ui:
		return
	if selected_entities.size() == 1:
		ui.call("update_unit_info", selected_entities[0])
	elif selected_entities.size() > 1:
		ui.call("update_multiple_units_info", selected_entities)
	else:
		ui.call("reset_ui")

func update_selection_rectangle():
	"""
	Met à jour la position et la taille du rectangle de sélection.
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
