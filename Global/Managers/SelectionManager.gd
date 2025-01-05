extends Control
class_name SelectionManager

##
## ================== PROPRIÉTÉS / VARIABLES ==================
##

# Listes d'unités réparties par faction / type
var player_units: Array = []  # Alliées
var enemy_units: Array = []   # Ennemies
var wild_units: Array = []    # Sauvages

# Liste de toutes les entités actuellement sélectionnées
# => On stockera des dictionnaires : { "unit": BaseUnit, "type": "ally"/"enemy"/"wild", "faction": String }
var selected_entities: Array = []

# État de la sélection rectangulaire
var selection_start: Vector2 = Vector2.ZERO
var selection_end: Vector2   = Vector2.ZERO
var is_selecting: bool       = false

# Référence à la caméra 2D (nécessaire pour conversions global->écran)
var camera: Camera2D = null

# Signaux pour avertir l’extérieur des changements
signal selection_updated(selected_entities: Array)
signal hovered_unit_changed(unit: BaseUnit)

# Gestion du curseur animé au survol
@export var cursor_images: Array = [
	"res://Assets/UI/Cursors/select_1.png",
	"res://Assets/UI/Cursors/select_2.png",
	"res://Assets/UI/Cursors/select_3.png",
	"res://Assets/UI/Cursors/select_4.png"
]
var cursor_animation_index: int = 0
var cursor_animation_timer: Timer = null
var hovered_unit: BaseUnit = null


##
## ================== FONCTIONS VIE DU NŒUD ==================
##

func _ready():
	# Création d’un Timer pour l’animation du curseur
	cursor_animation_timer = Timer.new()
	cursor_animation_timer.one_shot = false
	cursor_animation_timer.wait_time = 0.1
	cursor_animation_timer.connect("timeout", Callable(self, "_animate_cursor_frame"))
	add_child(cursor_animation_timer)

	# Curseur par défaut : première image
	if cursor_images.size() > 0:
		Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[0]))

##
## ================== FONCTIONS D'INITIALISATION ==================
##

func set_camera(camera_instance: Camera2D):
	camera = camera_instance

func initialize(player_units_container: Node, enemy_units_container: Node, wild_units_container: Node):
	# Récupération récursive de toutes les entités
	player_units = _gather_entities_recursive(player_units_container)
	enemy_units  = _gather_entities_recursive(enemy_units_container)
	wild_units   = _gather_entities_recursive(wild_units_container)
	clear_selection()

func _gather_entities_recursive(container: Node) -> Array:
	var entities = []
	for child in container.get_children():
		if child is BaseUnit:
			entities.append(child)
			child.set_selected(false)  # Désélection par défaut
		elif child is Node:
			entities += _gather_entities_recursive(child)
	return entities

##
## ================== GESTION DES ENTRÉES ==================
##

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button_input(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion_input(event)

func _handle_mouse_button_input(event: InputEventMouseButton) -> void:
	if not camera:
		return

	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Démarre la sélection rectangulaire
			start_selection(event.position)
		else:
			# Termine la sélection rectangulaire
			end_selection(event.position)

	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Clic droit : on désélectionne tout
		clear_selection()
		# On émet "selection_updated" (sera vide) => l’UI peut se réinitialiser
		emit_signal("selection_updated", selected_entities)

func _handle_mouse_motion_input(event: InputEventMouseMotion) -> void:
	# Survol d’une unité => animation du curseur
	var current_hovered = _detect_hovered_unit(event.position)
	if current_hovered != hovered_unit:
		# On arrête l’animation précédente
		if hovered_unit != null:
			_stop_cursor_animation()
		# On lance l’animation pour la nouvelle unité survolée
		if current_hovered != null:
			_animate_cursor_start(current_hovered)
		hovered_unit = current_hovered
		emit_signal("hovered_unit_changed", hovered_unit)

	# Mise à jour continue de la fin du rectangle si on est en train de sélectionner
	if is_selecting:
		selection_end = event.position
		queue_redraw()

##
## ================== SURVOL D’UNITÉ & CURSEUR ANIMÉ ==================
##

func _detect_hovered_unit(mouse_position: Vector2) -> BaseUnit:
	for unit in player_units + enemy_units + wild_units:
		if not unit or not camera:
			continue

		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if unit_screen_pos.distance_to(mouse_position) < 10:
			return unit
	return null

func _animate_cursor_start(unit: BaseUnit):
	cursor_animation_index = 0
	cursor_animation_timer.start()
	print("Unit hovered:", unit.name)

func _stop_cursor_animation():
	cursor_animation_timer.stop()
	# Restaure le curseur par défaut (première image)
	if cursor_images.size() > 0:
		Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[0]))

func _animate_cursor_frame():
	if cursor_images.size() < 1:
		return
	if cursor_animation_index < cursor_images.size():
		Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[cursor_animation_index]))
		cursor_animation_index = (cursor_animation_index + 1) % cursor_images.size()

##
## ================== SÉLECTION RECTANGULAIRE & CLIC ==================
##

func start_selection(screen_pos: Vector2) -> void:
	selection_start = screen_pos
	selection_end   = screen_pos
	is_selecting    = true
	queue_redraw()

func end_selection(screen_pos: Vector2) -> void:
	is_selecting = false
	selection_end = screen_pos
	queue_redraw()

	var selection_rect = Rect2(selection_start, selection_end - selection_start).abs()

	# Si le rectangle est minuscule => clic simple
	if selection_rect.size == Vector2.ZERO:
		_select_unit_by_click(selection_start)
	else:
		# Sélection rectangulaire multiple (uniquement sur units alliées)
		clear_selection()
		_select_entities_in_rectangle(selection_rect)

	# Émet toujours le signal => l’UI verra la nouvelle sélection (ou vide)
	emit_signal("selection_updated", selected_entities)

func _select_entities_in_rectangle(selection_rect: Rect2):
	# On ne prend que les alliés pour la sélection rect (RTS classique)
	for unit in player_units:
		var unit_screen_pos = camera.global_to_viewport(unit.global_position)
		if selection_rect.has_point(unit_screen_pos):
			_select_ally_unit(unit)

##
## ================== SÉLECTION PAR CLIC (ALLIÉ / ENNEMI / SAUVAGE) ==================
##

func _select_unit_by_click(click_position: Vector2) -> void:
	# On commence par nettoyer la sélection
	clear_selection()

	# 1) Essaie de sélectionner un allié
	var is_player = true
	if _check_and_select_individual(click_position, player_units, is_player):
		return

	# 2) Puis un ennemi
	var is_enemy = true
	if _check_and_select_individual(click_position, enemy_units, false, is_enemy):
		return

	# 3) Enfin une unité sauvage
	_check_and_select_individual(click_position, wild_units, false, false)

func _check_and_select_individual(click_position: Vector2, units: Array, is_player: bool, is_enemy: bool=false) -> bool:
	for unit in units:
		if not unit or not camera:
			continue

		var screen_pos = camera.global_to_viewport(unit.global_position)
		if screen_pos.distance_to(click_position) < 10:
			if is_player:
				_select_ally_unit(unit)
			elif is_enemy:
				_select_enemy_unit(unit)
			else:
				_select_wild_unit(unit)
			return true
	return false

##
## ================== AJOUT DE L’UNITÉ DANS selected_entities ==================
##
#  On ajoute "faction" pour aider l'UI à gérer le portrait & le son (ex: "Tha'Roon")

func _select_ally_unit(unit: BaseUnit) -> void:
	print("Sélection d'une unité alliée:", unit.name)
	unit.set_selected(true)

	var faction = "Unknown"
	if unit.stats and unit.stats.faction:
		faction = unit.stats.faction

	selected_entities.append({
		"unit": unit,
		"type": "ally",
		"faction": faction
	})
	_play_sound(unit)

func _select_enemy_unit(unit: BaseUnit) -> void:
	print("Sélection d'une unité ennemie:", unit.name)
	unit.set_selected(false)  # On ne contrôle pas l'ennemi

	var faction = "Unknown"
	if unit.stats and unit.stats.faction:
		faction = unit.stats.faction

	selected_entities.append({
		"unit": unit,
		"type": "enemy",
		"faction": faction
	})
	_play_sound(unit)

func _select_wild_unit(unit: BaseUnit) -> void:
	print("Sélection d'une unité sauvage:", unit.name)
	unit.set_selected(false)  # On ne contrôle pas le wild non plus

	var faction = "Unknown"
	if unit.stats and unit.stats.faction:
		faction = unit.stats.faction

	selected_entities.append({
		"unit": unit,
		"type": "wild",
		"faction": faction
	})
	_play_sound(unit)

func _play_sound(unit: BaseUnit) -> void:
	# Si l’unité dispose d’un chemin de son, on le joue
	if unit.stats and unit.stats.unit_sound_selection_path:
		SoundManager.play_sound_from_path(unit.stats.unit_sound_selection_path)

##
## ================== GESTION / RÉINITIALISATION DE LA SÉLECTION ==================
##

func clear_selection() -> void:
	# Désélectionne toutes les unités
	for unit in player_units + enemy_units + wild_units:
		if unit:
			unit.set_selected(false)
	selected_entities.clear()

##
## ================== DESSIN DU RECTANGLE DANS _draw() ==================
##

func _draw():
	# Si on est en train de sélectionner, dessine le rectangle vide
	if is_selecting:
		var top_left = Vector2(
			min(selection_start.x, selection_end.x),
			min(selection_start.y, selection_end.y)
		)
		var size = Vector2(
			abs(selection_end.x - selection_start.x),
			abs(selection_end.y - selection_start.y)
		)
		var rect = Rect2(top_left, size)

		# Couleur de bordure (ex : jaune) + épaisseur de trait = 2 px
		draw_rect(rect, Color("#ffc400"), false, 2.0)
