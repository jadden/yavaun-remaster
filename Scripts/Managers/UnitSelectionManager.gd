extends Control

# Gestion des unités
var units: Array = []
var selected_units: Array = []

# Gestion de la sélection
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2 = Vector2.ZERO
var is_selecting: bool = false

# Références aux nœuds de l'interface
var selection_rectangle: Panel
var unit_name_label: Label
var health_bar: ProgressBar
var mana_bar: ProgressBar
var help_panel: Panel
var help_label: Label

func _ready():
	# Initialisation des références
	selection_rectangle = $SelectionRectangle/Rectangle
	unit_name_label = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/Panel/UnitName")
	health_bar = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/Panel/HealthBar")
	mana_bar = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/Panel/ManaBar")
	help_panel = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/HelpPanel")
	help_label = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/HelpPanel/HelpLabel")

	# Vérification et masquage des nœuds
	_hide_ui_elements()

	# Initialisation des unités
	var units_container = get_node_or_null("../RaceSpecificUI/UI/UnitsContainer")
	if units_container:
		initialize(units_container)
	else:
		print("Erreur : UnitsContainer introuvable.")

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
		move_selected_units(event.position)

func start_selection(start_pos: Vector2):
	selection_start = start_pos
	selection_end = start_pos
	is_selecting = true
	selection_rectangle.visible = true
	update_selection_rectangle()

func update_selection(end_pos: Vector2):
	selection_end = end_pos
	update_selection_rectangle()

func end_selection():
	is_selecting = false
	selection_rectangle.visible = false
	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()
	selected_units.clear()

	for unit in units:
		if selection_rect.has_point(unit.global_position):
			unit.set_selected(true)
			selected_units.append(unit)
		else:
			unit.set_selected(false)

	update_ui_selection()

func clear_selection():
	for unit in selected_units:
		unit.set_selected(false)
	selected_units.clear()
	update_ui_selection()

func move_selected_units(target_position: Vector2):
	for unit in selected_units:
		unit.move_to(target_position)

func update_selection_rectangle():
	var top_left = selection_start
	var rect_size = selection_end - selection_start

	if rect_size.x < 0:
		top_left.x += rect_size.x
		rect_size.x = -rect_size.x
	if rect_size.y < 0:
		top_left.y += rect_size.y
		rect_size.y = -rect_size.y

	selection_rectangle.position = top_left
	selection_rectangle.size = rect_size

func update_ui_selection():
	if selected_units.size() == 1:
		var selected_unit = selected_units[0]
		unit_name_label.text = selected_unit.unit_name
		unit_name_label.visible = true
		health_bar.value = selected_unit.health
		health_bar.max_value = selected_unit.health_max
		health_bar.visible = true
		mana_bar.value = selected_unit.mana
		mana_bar.max_value = selected_unit.mana_max
		mana_bar.visible = true
	elif selected_units.size() > 1:
		unit_name_label.text = str(selected_units.size()) + " unités sélectionnées"
		unit_name_label.visible = true
		health_bar.visible = false
		mana_bar.visible = false
	else:
		_hide_ui_elements()

func _on_unit_mouse_entered(unit_name: String):
	help_label.text = "Type: " + unit_name
	help_panel.visible = true

func _on_unit_mouse_exited():
	help_panel.visible = false

func _process(delta):
	if help_panel and help_panel.visible:
		var mouse_pos = get_viewport().get_mouse_position()
		help_panel.position = mouse_pos + Vector2(10, 10)

func _hide_ui_elements():
	if unit_name_label:
		unit_name_label.visible = false
	if health_bar:
		health_bar.visible = false
	if mana_bar:
		mana_bar.visible = false
	if help_panel:
		help_panel.visible = false
