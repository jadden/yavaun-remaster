extends Control

# Gestion des unités
var units: Array = []
var selected_units: Array = []

# Gestion de la sélection
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
var is_selecting: bool = false

# Références aux nœuds de l'interface pour le rectangle de sélection
@onready var selection_rectangle: Panel = $SelectionRectangle/Rectangle

func _ready():
	# Assurez-vous que le rectangle de sélection est masqué au départ
	selection_rectangle.visible = false

func initialize(units_container: Node):
	# Initialise les unités à partir du conteneur donné
	units.clear()
	selected_units.clear()
	for unit in units_container.get_children():
		if unit is BaseUnit:
			unit.set_selected(false)
			units.append(unit)

func _input(event: InputEvent):
	handle_input(event)

func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion and is_selecting:
		update_selection(event.position)

func _handle_mouse_button_input(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_selection(event.position)
		else:
			end_selection()
	elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		# Déplacer les unités sélectionnées
		move_selected_units(event.position)

func start_selection(start_pos: Vector2):
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	# Afficher le rectangle de sélection
	selection_rectangle.visible = true
	update_selection_rectangle()

func update_selection(end_pos: Vector2):
	selection_end = end_pos
	update_selection_rectangle()

func end_selection():
	is_selecting = false
	# Masquer le rectangle de sélection
	selection_rectangle.visible = false
	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()
	selected_units.clear()

	for unit in units:
		if selection_rect.has_point(unit.global_position):
			unit.set_selected(true)
			selected_units.append(unit)
		else:
			unit.set_selected(false)

func clear_selection():
	for unit in selected_units:
		unit.set_selected(false)
	selected_units.clear()

func move_selected_units(target_position: Vector2):
	for unit in selected_units:
		unit.move_to(target_position)

# Met à jour la position et la taille du rectangle de sélection
func update_selection_rectangle():
	var top_left = selection_start
	var bottom_right = selection_end

	var rect_size = bottom_right - top_left
	if rect_size.x < 0:
		top_left.x += rect_size.x
		rect_size.x = -rect_size.x
	if rect_size.y < 0:
		top_left.y += rect_size.y
		rect_size.y = -rect_size.y

	selection_rectangle.position = top_left
	selection_rectangle.size = rect_size
