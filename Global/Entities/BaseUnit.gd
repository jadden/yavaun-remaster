extends CharacterBody2D
class_name BaseUnit

# Variables de configuration
@export var stats: UnitStats  # Statistiques de l'unité
@export var player_id: String = ""  # Identifiant du joueur ou de l'IA
@export var is_selected: bool = false  # État de sélection
@export var base_speed: float = 7.0  # Facteur de base pour calculer la vitesse réelle
@export var unit_menu_data: Dictionary = {  # Menu par défaut
	"Move": {},
	"Cancel": {}
}

# Références aux nœuds
@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var selection_box: Control = $SelectionBox
@onready var selection_animation: AnimationPlayer = $SelectionBox/SelectionAnimationPlayer
@onready var top_border: ColorRect = $SelectionBox/TopBorder
@onready var bottom_border: ColorRect = $SelectionBox/BottomBorder
@onready var left_border: ColorRect = $SelectionBox/LeftBorder
@onready var right_border: ColorRect = $SelectionBox/RightBorder
@onready var area2d: Area2D = $Area2D
@onready var circular_menu = $CircularMenu

# Variables internes
var move_speed: float = 0.0  # Vitesse réelle calculée
var current_direction: Vector2 = Vector2.DOWN  # Direction actuelle
var idle_timer: Timer = null  # Timer pour les animations idle

func _ready():
	# Initialisation de l'unité et de ses composants
	move_speed = stats.movement * base_speed
	_init_selection_box()
	_connect_signals()
	_play_idle_animation(current_direction)
	_init_idle_timer()

func set_player_id(player_id_value: String):
	# Définit l'ID du joueur propriétaire
	player_id = player_id_value
	print("BaseUnit - ID du joueur défini :", player_id)

func get_unit_menu_data() -> Dictionary:
	# Retourne les données de menu spécifiques à l'unité
	print("BaseUnit - Récupération du menu pour :", name, "-", unit_menu_data)
	return unit_menu_data

func set_selected(selected: bool, is_controllable: bool = true):
	# Change l'état de sélection de l'unité
	if circular_menu and circular_menu.is_open and not selected:
		print("Désélection ignorée car le menu circulaire est ouvert.")
		return

	is_selected = selected
	if selection_box:
		selection_box.visible = selected
		if selected:
			var border_color = Color(0, 1, 0) if is_controllable else Color(1, 0, 0)
			_set_border_color(border_color)
			if selection_animation and not selection_animation.is_playing():
				selection_animation.play("Effects/PulseSelectionBox")
		else:
			if selection_animation and selection_animation.is_playing():
				selection_animation.stop()

func execute_action(action: String):
	# Exécute une action spécifique à l'unité
	match action:
		"Move":
			print("Déplacer l'unité :", name)
		"Attack":
			print("Attaquer avec l'unité :", name)
		"Cancel":
			print("Action annulée.")

func move_to(target_position: Vector2):
	# Déplace l'unité vers une position cible
	if not is_selected:
		return

	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)

	if distance > 0:
		current_direction = direction
		_play_walk_animation(direction)

		var travel_time = distance / move_speed
		var tween = create_tween()
		tween.tween_property(self, "global_position", target_position, travel_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(Callable(self, "_on_movement_finished"))
	else:
		_on_movement_finished()

func _on_movement_finished():
	# Gère la fin du mouvement
	_play_idle_animation(current_direction)

func _init_selection_box():
	# Configure la boîte de sélection
	if selection_box:
		selection_box.visible = false
	else:
		print("Erreur : SelectionBox introuvable.")

func _set_border_color(color: Color):
	# Définit la couleur des bordures
	for border in [top_border, bottom_border, left_border, right_border]:
		border.color = color

func _connect_signals():
	# Connecte les signaux pour les interactions utilisateur
	if area2d:
		area2d.connect("input_event", Callable(self, "_on_input_event"))
		print("Connecté")
	else:
		print("Erreur : Area2D introuvable.")

func _init_idle_timer():
	# Initialise le timer pour les animations idle
	idle_timer = Timer.new()
	idle_timer.wait_time = 30.0
	idle_timer.one_shot = false
	idle_timer.connect("timeout", Callable(self, "_play_random_idle_animation"))
	add_child(idle_timer)
	idle_timer.start()

func _play_walk_animation(direction: Vector2):
	# Joue l'animation de marche
	var direction_name = _get_direction_name(direction)
	if direction_name != "":
		animator.flip_h = direction.x < 0
		animator.play("walk_" + direction_name)

func _play_idle_animation(direction: Vector2):
	# Joue l'animation idle
	var direction_name = _get_direction_name(direction)
	if animator and direction_name != "":
		animator.play("idle_" + direction_name)

func _play_random_idle_animation():
	# Joue une animation idle aléatoire
	var random_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	current_direction = random_direction
	_play_idle_animation(random_direction)

func _get_direction_name(direction: Vector2) -> String:
	# Retourne le nom de la direction
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y > 0 else "up"

#func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	# Gère les événements utilisateur
#	if event is InputEventMouseButton and event.pressed:
#		if event.button_index == MOUSE_BUTTON_LEFT:
#			set_selected(true, player_id == "Player1")
#		elif event.button_index == MOUSE_BUTTON_RIGHT:
#			print("Clic droit détecté pour :", name)
#			var menu_data = get_unit_menu_data()
#			print("BaseUnit - Menu récupéré :", menu_data)
#			circular_menu.open_menu(menu_data)

func apply_selection_color(color: Color):
	# Applique une couleur spécifique aux bordures
	for border in [top_border, bottom_border, left_border, right_border]:
		border.color = color
