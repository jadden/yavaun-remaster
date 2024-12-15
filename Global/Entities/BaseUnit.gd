extends CharacterBody2D
class_name BaseUnit

# Variables de configuration
@export var stats: UnitStats  # Statistiques de l'unité
@export var player_id: String = ""  # Identifiant du joueur ou de l'IA
@export var is_selected: bool = false  # État de sélection
@export var base_speed: float = 7.0  # Facteur de base pour calculer la vitesse réelle

# Références aux nœuds
@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var selection_box: Control = $SelectionBox
@onready var selection_animation: AnimationPlayer = $SelectionBox/SelectionAnimationPlayer
@onready var top_border: ColorRect = $SelectionBox/TopBorder
@onready var bottom_border: ColorRect = $SelectionBox/BottomBorder
@onready var left_border: ColorRect = $SelectionBox/LeftBorder
@onready var right_border: ColorRect = $SelectionBox/RightBorder
@onready var area2d: Area2D = $Area2D

# Variables de gestion de mouvement
var current_direction: Vector2 = Vector2.DOWN  # Direction actuelle
var move_speed: float = 0.0  # Vitesse réelle calculée à partir des stats
var idle_timer: Timer = null  # Timer pour les animations idle aléatoires

func _ready():
	"""
	Initialisation de l'unité et configuration des composants.
	"""
	move_speed = stats.movement * base_speed  # Calcule la vitesse réelle
	_init_selection_box()
	_connect_signals()
	_play_idle_animation(current_direction)
	_init_idle_timer()

func _init_selection_box():
	"""
	Configure la boîte de sélection.
	"""
	if selection_box:
		selection_box.visible = false  # Masque la boîte de sélection par défaut
	else:
		print("Erreur : SelectionBox introuvable.")
	
	if not selection_animation:
		print("Erreur : AnimationPlayer introuvable.")

func _connect_signals():
	"""
	Connecte les signaux de l'Area2D pour gérer les interactions.
	"""
	if area2d:
		area2d.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		area2d.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		area2d.connect("input_event", Callable(self, "_on_input_event"))
	else:
		print("Erreur : Area2D introuvable.")

func _init_idle_timer():
	"""
	Initialise un timer pour jouer des animations idle aléatoires.
	"""
	idle_timer = Timer.new()
	idle_timer.wait_time = 30.0  # Toutes les 30 secondes
	idle_timer.one_shot = false
	idle_timer.connect("timeout", Callable(self, "_play_random_idle_animation"))
	add_child(idle_timer)
	idle_timer.start()

func set_player_id(player_id_value: String):
	"""
	Définit l'ID du joueur propriétaire de l'unité.
	"""
	player_id = player_id_value

func set_selected(selected: bool, is_controllable: bool = true):
	"""
	Change l'état de sélection de l'unité et applique une couleur spécifique.
	"""
	is_selected = selected
	if selection_box:
		selection_box.visible = selected
		if selected:
			var border_color = Color(0, 1, 0) if is_controllable else Color(1, 0, 0)  # Vert pour alliés, rouge pour ennemis
			_set_border_color(border_color)
			if selection_animation and not selection_animation.is_playing():
				selection_animation.play("Effects/PulseSelectionBox")
		else:
			if selection_animation and selection_animation.is_playing():
				selection_animation.stop()

func _set_border_color(color: Color):
	"""
	Définit la couleur des bordures de la boîte de sélection.
	"""
	for border in [top_border, bottom_border, left_border, right_border]:
		border.color = color

func move_to(target_position: Vector2):
	"""
	Déplace l'unité vers une position cible.
	"""
	if not is_selected:
		return  # Ne permet de déplacer que les unités sélectionnées et contrôlées

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

func _play_walk_animation(direction: Vector2):
	"""
	Joue l'animation de marche basée sur la direction.
	"""
	var direction_name = _get_direction_name(direction)
	if direction_name != "":
		animator.flip_h = direction.x < 0  # Gère le flip horizontal
		animator.play("walk_" + direction_name)

func _play_idle_animation(direction: Vector2):
	"""
	Joue l'animation idle pour la direction actuelle.
	"""
	var direction_name = _get_direction_name(direction)
	if animator == null:
		return
	if direction_name != "":
		animator.play("idle_" + direction_name)

func _play_random_idle_animation():
	"""
	Joue une animation idle dans une direction aléatoire.
	"""
	var random_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	current_direction = random_direction
	_play_idle_animation(random_direction)

func _get_direction_name(direction: Vector2) -> String:
	"""
	Retourne le nom de la direction basé sur le vecteur de direction.
	"""
	if abs(direction.x) > abs(direction.y):  # Prédominance horizontale
		return "right" if direction.x > 0 else "left"
	else:  # Prédominance verticale
		return "down" if direction.y > 0 else "up"

func _on_movement_finished():
	"""
	Gère la logique lorsque le mouvement est terminé.
	"""
	_play_idle_animation(current_direction)

# Gestion des événements de souris
func _on_mouse_entered():
	"""
	Gère l'événement lorsque la souris survole l'unité.
	"""
	print("Souris survole :", name)

func _on_mouse_exited():
	"""
	Gère l'événement lorsque la souris quitte l'unité.
	"""
	print("Souris quitte :", name)

func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	"""
	Gère les interactions utilisateur sur la zone de collision.
	"""
	if event is InputEventMouseButton and event.pressed:
		var is_unit_controllable = player_id == "Player1"
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_selected(true, is_unit_controllable)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			set_selected(false)

func apply_selection_color(color: Color):
	"""
	Applique une couleur spécifique aux bordures de sélection.
	"""
	for border in [top_border, bottom_border, left_border, right_border]:
		border.color = color
