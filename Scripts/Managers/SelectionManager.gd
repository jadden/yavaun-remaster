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

# Références aux nœuds de l'interface
@onready var selection_rectangle: Panel = $SelectionRectangle/Rectangle
@onready var unit_name_label: Label = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/Panel/UnitName")
@onready var health_bar: ProgressBar = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/Panel/HealthBar")
@onready var mana_bar: ProgressBar = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/Panel/ManaBar")
@onready var help_panel: Panel = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/HelpPanel")
@onready var help_label: Label = get_node_or_null("/root/GlobalMap/UI/RaceSpecificUI/UI/HelpPanel/HelpLabel")

func _ready():
	_hide_ui_elements()
	# Initialisation des entités
	var entities_container = get_node_or_null("../RaceSpecificUI/UI/EntitiesContainer")
	if entities_container:
		initialize(entities_container)
	else:
		print("Erreur : EntitiesContainer introuvable.")

func initialize(entities_container: Node):
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
			print("Erreur : Entité inconnue détectée :", entity.name)

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
		move_selected_entities(event.position)

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
	selected_entities.clear()

	for entity in units + buildings:
		if selection_rect.has_point(entity.global_position):
			entity.set_selected(true)
			selected_entities.append(entity)
		else:
			entity.set_selected(false)

	update_ui_selection()

func clear_selection():
	for entity in selected_entities:
		entity.set_selected(false)
	selected_entities.clear()
	update_ui_selection()

func move_selected_entities(target_position: Vector2):
	for entity in selected_entities:
		if entity.has_method("move_to"):
			entity.move_to(target_position)

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
	if selected_entities.size() == 1:
		var selected_entity = selected_entities[0]
		if selected_entity is BaseUnit:
			_update_unit_ui(selected_entity)
		elif selected_entity is BaseBuilding:
			_update_building_ui(selected_entity)
	elif selected_entities.size() > 1:
		unit_name_label.text = str(selected_entities.size()) + " entités sélectionnées"
		unit_name_label.visible = true
		health_bar.visible = false
		mana_bar.visible = false
	else:
		_hide_ui_elements()

func _update_unit_ui(unit: BaseUnit):
	if not unit:
		print("Erreur : Unité invalide.")
		return
	unit_name_label.text = unit.stats.unit_name
	unit_name_label.visible = true
	health_bar.value = unit.stats.health
	health_bar.max_value = unit.stats.health_max
	health_bar.visible = true
	mana_bar.value = unit.stats.mana
	mana_bar.max_value = unit.stats.mana_max
	mana_bar.visible = true

func _update_building_ui(building: BaseBuilding):
	if not building:
		print("Erreur : Bâtiment invalide.")
		return
	unit_name_label.text = building.building_name
	unit_name_label.visible = true
	health_bar.value = building.health
	health_bar.max_value = building.max_health
	health_bar.visible = true
	mana_bar.visible = false

func _on_entity_mouse_entered(entity_name: String):
	help_label.text = "Type: " + entity_name
	help_panel.visible = true

func _on_entity_mouse_exited():
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
