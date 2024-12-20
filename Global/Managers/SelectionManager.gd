extends Control
class_name SelectionManager

# Gestion des entités
var player_units: Array = []  # Liste des unités alliées
var enemy_units: Array = []   # Liste des unités ennemies
var wild_units: Array = []    # Liste des unités sauvages
var selected_entities: Array = []  # Liste des entités sélectionnées (alliées uniquement)

# Portraits et sons par faction
@export var faction_portraits: Dictionary = {
	"Tha'Roon": "res://ThaRoon/Assets/Portraits/tharoon.png"
}
@export var faction_selection_sounds: Dictionary = {
	"Tha'Roon": "res://ThaRoon/Assets/Sounds/tharoon.wav"
}

# Gestion de la sélection
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
var is_selecting: bool = false

# Références aux nœuds
@onready var selection_rectangle: Control = $SelectionRectangle
@onready var rectangle_panel: Control = $SelectionRectangle/Rectangle
var camera: Camera2D = null  # Référence à la caméra
var ui: ShamaLiUI = null  # Référence à l'interface utilisateur
var player_id: String = "Player1"  # ID du joueur actuel (allié)

# Couleur de sélection pour unités non contrôlées
@export var non_controllable_color: Color = Color(1, 0, 0)  # Rouge

# Curseur d'animation
@export var cursor_images: Array = [
	"res://Assets/UI/Cursors/select_1.png",
	"res://Assets/UI/Cursors/select_2.png",
	"res://Assets/UI/Cursors/select_3.png",
	"res://Assets/UI/Cursors/select_4.png"
]
var cursor_animation_index: int = 0
var cursor_animation_timer: Timer = null
var hovered_unit: BaseUnit = null

func _ready():
	"""
	Initialise les références et cache les éléments visuels.
	"""
	if selection_rectangle:
		selection_rectangle.visible = false
		selection_rectangle.mouse_filter = Control.MOUSE_FILTER_IGNORE

	cursor_animation_timer = Timer.new()
	cursor_animation_timer.one_shot = false
	cursor_animation_timer.wait_time = 0.1
	cursor_animation_timer.connect("timeout", Callable(self, "_animate_cursor_frame"))
	add_child(cursor_animation_timer)

	# Définir le curseur par défaut
	Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[0]))

func set_camera(camera_instance: Camera2D):
	"""
	Définit la caméra associée au gestionnaire.
	"""
	camera = camera_instance

func set_ui(ui_instance: ShamaLiUI):
	"""
	Définit l'interface utilisateur associée au gestionnaire.
	"""
	ui = ui_instance

func initialize(player_units_container: Node, enemy_units_container: Node, wild_units_container: Node):
	"""
	Initialise les conteneurs des entités alliées, ennemies et sauvages.
	"""
	player_units = _gather_entities_recursive(player_units_container)
	enemy_units = _gather_entities_recursive(enemy_units_container)
	wild_units = _gather_entities_recursive(wild_units_container)
	selected_entities.clear()

func _gather_entities_recursive(container: Node) -> Array:
	"""
	Récupère récursivement les entités dans un conteneur donné.
	"""
	var entities = []
	for child in container.get_children():
		if child is BaseUnit:
			entities.append(child)
			child.set_selected(false)  # Désélectionne par défaut
		elif child is Node:
			entities += _gather_entities_recursive(child)
	return entities

func _input(event: InputEvent):
	"""
	Gère les entrées utilisateur pour la sélection et le déplacement.
	"""
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion_input(event)

func _handle_mouse_button_input(event: InputEventMouseButton):
	"""
	Gère les clics souris pour démarrer/arrêter une sélection ou afficher des informations.
	"""
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_selection(event.position)
		else:
			end_selection(event.position)
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		clear_selection()

func _handle_mouse_motion_input(event: InputEventMouseMotion):
	"""
	Gère le mouvement de la souris pour animer le curseur lors du survol d'une unité.
	"""
	var current_hovered_unit = _detect_hovered_unit(event.position)
	if current_hovered_unit != hovered_unit:
		if hovered_unit != null:
			_stop_cursor_animation()
		if current_hovered_unit != null:
			animate_cursor_for_selection(current_hovered_unit)
		hovered_unit = current_hovered_unit

	if is_selecting:
		update_selection(event.position)

func _detect_hovered_unit(mouse_position: Vector2) -> BaseUnit:
	"""
	Détecte l'unité sous la souris, s'il y en a une.
	"""
	for unit in player_units + enemy_units + wild_units:
		if not unit or not camera:
			continue

		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if unit_screen_pos.distance_to(mouse_position) < 10:
			return unit
	return null

func animate_cursor_for_selection(unit: BaseUnit):
	"""
	Lance l'animation du curseur pour indiquer qu'une unité est survolée.
	"""
	cursor_animation_index = 0  # Réinitialise l'animation
	cursor_animation_timer.start()
	print("Unit hovered: " + unit.name)

func _stop_cursor_animation():
	"""
	Arrête l'animation du curseur.
	"""
	cursor_animation_timer.stop()
	Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[0]))  # Retour au curseur par défaut

func _animate_cursor_frame():
	"""
	Met à jour l'image du curseur pour animer l'effet.
	"""
	if cursor_animation_index < cursor_images.size():
		Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[cursor_animation_index]))
		cursor_animation_index = (cursor_animation_index + 1) % cursor_images.size()

func start_selection(start_pos: Vector2):
	"""
	Démarre une sélection rectangulaire.
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
	Termine la sélection et sélectionne les entités dans le rectangle.
	"""
	is_selecting = false
	selection_rectangle.visible = false
	selection_end = end_pos

	if not camera:
		print("Erreur : Caméra non définie.")
		return

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()

	if selection_rect.size == Vector2.ZERO:
		_select_unit_by_click(selection_start)
	else:
		clear_selection()
		_select_entities_in_rectangle(selection_rect)

	update_ui()

func _select_unit_by_click(click_position: Vector2):
	"""
	Sélectionne une unité individuellement via un clic unique.
	"""
	clear_selection()  # Réinitialise toutes les sélections avant de traiter le clic

	# Priorité : Alliés -> Ennemis -> Sauvages
	if _check_and_select_individual(click_position, player_units, true):
		return
	if _check_and_select_individual(click_position, enemy_units, false, true):
		return
	_check_and_select_individual(click_position, wild_units, false, false)

func _check_and_select_individual(click_position: Vector2, units: Array, is_player_unit: bool, is_enemy: bool = false) -> bool:
	"""
	Vérifie et sélectionne une unité proche de la position de clic.
	"""
	for unit in units:
		if not unit or not camera:
			continue

		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if unit_screen_pos.distance_to(click_position) < 10:
			if is_player_unit:
				_select_unit(unit, true)
			elif is_enemy:
				_select_enemy_unit(unit)
			else:
				_select_wild_unit(unit)
			return true
	return false

func _select_entities_in_rectangle(selection_rect: Rect2):
	"""
	Sélectionne uniquement les unités contrôlées dans un rectangle donné.
	"""
	for unit in player_units:
		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if selection_rect.has_point(unit_screen_pos):
			_select_unit(unit, true)

func _select_unit(unit: BaseUnit, is_player_unit: bool):
	"""
	Ajoute une unité sélectionnée à la liste et applique les effets visuels/audio.
	"""
	unit.set_selected(is_player_unit)

	if not is_player_unit:
		# Applique une bordure rouge pour les unités non contrôlées
		unit.apply_selection_color(non_controllable_color)

	if is_player_unit:
		selected_entities.append(unit)

	# Mets à jour l'UI pour les unités non contrôlées
	if ui and not is_player_unit:
		ui.update_unit_info(unit)
		ui.update_unit_health(unit, unit.stats.health)

	if ui and is_player_unit:
		ui.update_unit_info(unit)

	_play_sound(unit)

func _play_sound(unit: BaseUnit):
	"""
	Joue le son associé à une unité.
	"""
	if unit.stats and unit.stats.unit_sound_selection_path:
		SoundManager.play_sound_from_path(unit.stats.unit_sound_selection_path)

func _select_enemy_unit(unit: BaseUnit):
	"""
	Gère la sélection d'une unité ennemie.
	"""
	if ui:
		var faction = unit.stats.faction if unit.stats else "Unknown"
		var portrait_path = faction_portraits.get(faction, "res://DefaultPortrait.png")
		var sound_path = faction_selection_sounds.get(faction, "res://DefaultSound.wav")
		ui.update_generic_enemy_info(faction, portrait_path)
		if sound_path:
			SoundManager.play_sound_from_path(sound_path)

func _select_wild_unit(unit: BaseUnit):
	"""
	Gère la sélection d'une unité sauvage.
	"""
	if ui:
		ui.update_unit_info(unit)
		_play_sound(unit)

func clear_selection():
	"""
	Réinitialise toutes les sélections.
	"""
	for unit in player_units + enemy_units + wild_units:
		unit.set_selected(false)
	selected_entities.clear()

	if ui:
		ui.reset_ui()

func update_ui():
	"""
	Met à jour l'interface utilisateur avec les informations des entités sélectionnées.
	"""
	if not ui:
		return

	if selected_entities.size() == 1:
		ui.update_unit_info(selected_entities[0])
	elif selected_entities.size() > 1:
		ui.update_multiple_units_info(selected_entities)
	else:
		ui.reset_ui()

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
