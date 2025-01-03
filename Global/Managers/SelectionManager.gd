extends Control
class_name SelectionManager

# Gestion des entités
var player_units: Array = []  # Liste des unités alliées
var enemy_units: Array = []   # Liste des unités ennemies
var wild_units: Array = []    # Liste des unités sauvages
var selected_entities: Array = []  # Liste des entités sélectionnées

# Gestion de la sélection
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
var is_selecting: bool = false

# Références
@onready var selection_rectangle: Control = $SelectionRectangle
var camera: Camera2D = null  # Référence à la caméra

# Signaux
signal selection_updated(selected_entities: Array)
signal hovered_unit_changed(unit: BaseUnit)

func _ready():
	if selection_rectangle:
		selection_rectangle.visible = false
		selection_rectangle.mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_camera(camera_instance: Camera2D):
	camera = camera_instance

func initialize(player_units_container: Node, enemy_units_container: Node, wild_units_container: Node):
	player_units = _gather_entities_recursive(player_units_container)
	enemy_units = _gather_entities_recursive(enemy_units_container)
	wild_units = _gather_entities_recursive(wild_units_container)
	clear_selection()

func _gather_entities_recursive(container: Node) -> Array:
	var entities = []
	for child in container.get_children():
		if child is BaseUnit:
			entities.append(child)
			child.set_selected(false)
		elif child is Node:
			entities += _gather_entities_recursive(child)
	return entities

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion_input(event)

func _handle_mouse_button_input(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_selection(event.position)
		else:
			end_selection(event.position)

func start_selection(start_pos: Vector2):
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	selection_rectangle.visible = true
	update_selection_rectangle()

func end_selection(end_pos: Vector2):
	is_selecting = false
	selection_rectangle.visible = false
	selection_end = end_pos

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()

	if selection_rect.size == Vector2.ZERO:
		_select_unit_by_click(selection_start)
	else:
		_select_entities_in_rectangle(selection_rect)

	emit_signal("selection_updated", selected_entities)

func _select_entities_in_rectangle(selection_rect: Rect2):
	for unit in player_units:
		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if selection_rect.has_point(unit_screen_pos):
			_select_unit(unit)

func _select_unit_by_click(click_position: Vector2):
	for unit in player_units + enemy_units + wild_units:
		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if unit_screen_pos.distance_to(click_position) < 10:
			_select_unit(unit)
			break

func _select_unit(unit: BaseUnit):
	unit.set_selected(true)
	selected_entities.append(unit)

func _handle_mouse_motion_input(event: InputEventMouseMotion):
	var hovered_unit = _detect_hovered_unit(event.position)
	if hovered_unit:
		emit_signal("hovered_unit_changed", hovered_unit)

func _detect_hovered_unit(mouse_position: Vector2) -> BaseUnit:
	for unit in player_units + enemy_units + wild_units:
		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if unit_screen_pos.distance_to(mouse_position) < 10:
			return unit
	return null

func clear_selection():
	for unit in player_units + enemy_units + wild_units:
		unit.set_selected(false)
	selected_entities.clear()
	emit_signal("selection_updated", selected_entities)

func update_selection_rectangle():
	var top_left = Vector2(
		min(selection_start.x, selection_end.x),
		min(selection_start.y, selection_end.y)
	)
	var rect_size = Vector2(
		abs(selection_end.x - selection_start.x),
		abs(selection_end.y - selection_start.y)
	)
	selection_rectangle.position = top_left
	selection_rectangle.size = rect_size
