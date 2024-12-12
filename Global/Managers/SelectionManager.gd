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
@onready var path_animation: AnimatedSprite2D = $PathAnimation  # Animation pour le point de déplacement
var camera: Camera2D = null  # Référence à la caméra
var ui: Node = null  # Référence à l'interface utilisateur
var player_id: String = "Player1"  # ID du joueur actuel

func _ready():
	"""
	Initialise les références et cache les éléments visuels.
	"""
	if selection_rectangle and rectangle_panel:
		selection_rectangle.visible = false
		selection_rectangle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("SelectionManager prêt. Rectangle de sélection masqué.")
	else:
		print("Erreur : Les nœuds `SelectionRectangle` ou `Rectangle` sont manquants.")

	if path_animation:
		path_animation.visible = false

func set_ui(ui_instance: Node):
	"""
	Associe l'interface utilisateur au gestionnaire.
	"""
	ui = ui_instance
	print("UI correctement associée :", ui.name)

func set_camera(camera_instance: Camera2D):
	"""
	Associe la caméra au gestionnaire.
	"""
	camera = camera_instance
	print("Caméra définie pour SelectionManager :", camera.name)

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
			units.append(child)
			child.set_selected(false)
		elif child is BaseBuilding:
			buildings.append(child)
			child.set_selected(false)
		elif child is Node:
			gather_entities_recursive(child)

func _input(event: InputEvent):
	"""
	Gère les événements utilisateur pour la sélection et le déplacement.
	"""
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion and is_selecting:
		update_selection(event.position)

func _handle_mouse_button_input(event: InputEventMouseButton):
	"""
	Gère les clics pour commencer ou terminer une sélection ou déplacer des unités.
	"""
	if event.button_index == MOUSE_BUTTON_LEFT:
		if selected_entities.size() > 0 and not is_selecting:
			start_move_selected_units(event.position)
		elif event.pressed:
			start_selection(event.position)
		else:
			end_selection(event.position)
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		clear_selection()

func start_move_selected_units(target_screen_pos: Vector2):
	"""
	Anime le point de destination et déplace les unités sélectionnées vers la position cible.
	"""
	if camera == null:
		print("Erreur : Caméra non définie pour le déplacement.")
		return

	# Convertit la position écran en position monde
	var target_world_pos = camera.get_global_mouse_position()
	print("Cible du déplacement :", target_world_pos)

	# Affiche et anime le PathAnimation au point cliqué
	if path_animation:
		path_animation.global_position = target_world_pos
		path_animation.visible = true
		path_animation.play("move_point")  # Joue l'animation de croix

		# Attend la fin de l'animation
		var animation_frames = path_animation.sprite_frames.get_frame_count("move_point")
		var animation_fps = path_animation.sprite_frames.get_animation_speed("move_point")
		var animation_duration = animation_frames / animation_fps

		await get_tree().create_timer(animation_duration).timeout
		path_animation.visible = false

	# Démarre le déplacement des unités sélectionnées
	for entity in selected_entities:
		entity.start_moving(target_world_pos)

func start_selection(start_pos: Vector2):
	"""
	Démarre une sélection avec la position initiale.
	"""
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

func end_selection(end_pos: Vector2):
	"""
	Termine la sélection et met à jour les entités sélectionnées.
	"""
	is_selecting = false
	selection_rectangle.visible = false
	selection_end = end_pos

	if camera == null:
		print("Erreur : Caméra non définie.")
		return

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()

	clear_selection()  # Réinitialise toutes les unités avant de sélectionner de nouvelles

	for entity in units:
		if not entity:
			continue

		var entity_screen_pos = camera.global_to_viewport(entity.global_position)
		
		# Sélection par clic ou rectangle
		if selection_rect.size == Vector2.ZERO:
			if entity_screen_pos.distance_to(selection_start) < 10:  # Tolérance pour clic unique
				select_entity(entity)
				break  # Un seul clic suffit
		elif selection_rect.has_point(entity_screen_pos):
			select_entity(entity)

	print("Sélection terminée. Entités sélectionnées :", selected_entities)
	update_ui()

func select_entity(entity: BaseUnit):
	"""
	Sélectionne une entité et l'ajoute à la liste.
	"""
	if entity.player_id == player_id:
		entity.set_selected(true)
		selected_entities.append(entity)

func clear_selection():
	"""
	Désélectionne toutes les entités et réinitialise visuellement la sélection.
	"""
	for entity in units:
		entity.set_selected(false)  # Désélectionne et masque la box visuelle
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
	var top_left = Vector2(
		min(selection_start.x, selection_end.x),
		min(selection_start.y, selection_end.y)
	)
	var rect_size = Vector2(
		abs(selection_end.x - selection_start.x),
		abs(selection_end.y - selection_start.y)
	)
	rectangle_panel.position = top_left
	rectangle_panel.size = rect_size
