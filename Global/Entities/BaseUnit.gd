extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats  # Informations sur l'unité
@export var player_id: String = ""  # Identifiant du joueur ou de l'entité IA
@export var is_selected: bool = false  # État de sélection de l'unité
@export var move_speed: float = 50.0  # Vitesse de déplacement par défaut

# Références aux nœuds
@onready var selection_box: Control = $SelectionBox
@onready var selection_animation: AnimationPlayer = $SelectionBox/SelectionAnimationPlayer
@onready var area2d: Area2D = $Area2D  # Zone d'interaction pour les événements d'entrée

# Curseur animé
var cursor_animation_running: bool = false
var cursor_frames: Array = [
	"res://Assets/UI/Cursors/select_1.png",
	"res://Assets/UI/Cursors/select_2.png",
	"res://Assets/UI/Cursors/select_3.png",
	"res://Assets/UI/Cursors/select_4.png"
]
var current_cursor_index: int = 0
var cursor_animation_timer: Timer = null

func _ready():
	"""
	Initialise l'unité et configure les composants nécessaires.
	"""
	print("Initialisation de BaseUnit :", name)

	# Configure la boîte de sélection
	if selection_box:
		selection_box.visible = false
		print("SelectionBox trouvée :", selection_box.name)
	else:
		print("Erreur : SelectionBox introuvable.")

	# Configure l'AnimationPlayer pour la sélection
	if selection_animation:
		print("AnimationPlayer trouvé :", selection_animation.name)
	else:
		print("Erreur : AnimationPlayer introuvable.")

	# Connecte les signaux de l'Area2D
	if area2d:
		_connect_signals()
	else:
		print("Erreur : Area2D introuvable.")

	# Initialise le timer pour l'animation du curseur
	_init_cursor_timer()

func _connect_signals():
	"""
	Connecte les signaux de l'Area2D en évitant les doublons.
	"""
	var entered_callable = Callable(self, "_on_mouse_entered")
	if not area2d.is_connected("mouse_entered", entered_callable):
		area2d.connect("mouse_entered", entered_callable)

	var exited_callable = Callable(self, "_on_mouse_exited")
	if not area2d.is_connected("mouse_exited", exited_callable):
		area2d.connect("mouse_exited", exited_callable)

	var input_callable = Callable(self, "_on_collision_area_input_event")
	if not area2d.is_connected("input_event", input_callable):
		area2d.connect("input_event", input_callable)

	var area_entered_callable = Callable(self, "_on_area_2d_area_entered")
	if not area2d.is_connected("area_entered", area_entered_callable):
		area2d.connect("area_entered", area_entered_callable)

	var area_exited_callable = Callable(self, "_on_area_2d_area_exited")
	if not area2d.is_connected("area_exited", area_exited_callable):
		area2d.connect("area_exited", area_exited_callable)

	print("Connexion des signaux Area2D effectuée.")

func _init_cursor_timer():
	"""
	Initialise le timer pour animer le curseur.
	"""
	cursor_animation_timer = Timer.new()
	cursor_animation_timer.wait_time = 0.2  # Change d'image toutes les 0.2 secondes
	cursor_animation_timer.one_shot = false
	cursor_animation_timer.connect("timeout", Callable(self, "_animate_cursor"))
	add_child(cursor_animation_timer)

func set_player_id(player_id_value: String):
	"""
	Définit l'ID du joueur propriétaire de l'unité.
	"""
	player_id = player_id_value
	print("Propriétaire défini :", player_id)

func set_selected(selected: bool):
	"""
	Définit l'état de sélection de l'unité et gère l'animation de sélection.
	"""
	is_selected = selected

	if selection_box:
		selection_box.visible = selected  # Affiche ou masque visuellement la boîte de sélection

	if selected:
		print("Unité sélectionnée :", name)
		if selection_animation and not selection_animation.is_playing():
			selection_animation.play("Effects/PulseSelectionBox")
	else:
		print("Unité désélectionnée :", name)
		if selection_animation and selection_animation.is_playing():
			selection_animation.stop()

func start_moving(target_position: Vector2):
	"""
	Déplace l'unité vers une position cible de manière progressive et gère la fin du mouvement.
	"""
	if stats.movement <= 0:
		print("Vitesse de déplacement invalide pour", name)
		return

	# Calcule le temps de déplacement en fonction de la vitesse individuelle
	var distance = global_position.distance_to(target_position)
	var travel_time = distance / (move_speed * (stats.movement / 7.0))  # 7 est la vitesse de référence moyenne

	# Création d'un Tween et animation
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, travel_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	print("Déplacement de", name, "vers", target_position, "en", travel_time, "secondes (mouvement :", stats.movement, ").")

	# Connexion de l'événement terminé
	tween.finished.connect(self._on_tween_finished)


func _on_tween_finished():
	"""
	Gère la logique une fois le déplacement terminé.
	"""
	print("Déplacement terminé pour :", name)
	# Vous pouvez ajouter d'autres actions ici, par exemple des mises à jour visuelles ou déclencher un nouvel état.

func _on_mouse_entered():
	"""
	Gère l'événement lorsque la souris survole l'unité.
	"""
	print("Souris survole :", name, "à la position :", global_position)
	if not cursor_animation_running:
		cursor_animation_running = true
		current_cursor_index = 0  # Réinitialise l'animation
		cursor_animation_timer.start()

func _on_mouse_exited():
	"""
	Gère l'événement lorsque la souris quitte le survol de l'unité.
	"""
	print("Souris quitte :", name, "à la position :", global_position)
	if cursor_animation_running:
		cursor_animation_running = false
		cursor_animation_timer.stop()
		Input.set_custom_mouse_cursor(null)  # Réinitialise le curseur par défaut

func _animate_cursor():
	"""
	Change dynamiquement le curseur pour donner l'illusion d'une animation.
	"""
	if cursor_animation_running and current_cursor_index < cursor_frames.size():
		var cursor_path = cursor_frames[current_cursor_index]
		var cursor_texture = load(cursor_path)
		if cursor_texture and cursor_texture is Texture2D:
			Input.set_custom_mouse_cursor(cursor_texture)
		current_cursor_index = (current_cursor_index + 1) % cursor_frames.size()

func _on_collision_area_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	"""
	Gère les interactions utilisateur sur la zone de collision.
	"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clic gauche détecté sur :", name)
			set_selected(true)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Clic droit détecté sur :", name)
			set_selected(false)

func _on_area_2d_area_entered(area: Area2D):
	"""
	Gère l'événement lorsqu'une autre zone entre en collision avec l'Area2D.
	"""
	print("Zone entrée dans :", name, "par :", area)
	if selection_animation:
		selection_animation.play("Effects/Highlight")

func _on_area_2d_area_exited(area: Area2D):
	"""
	Gère l'événement lorsqu'une autre zone quitte la collision avec l'Area2D.
	"""
	print("Zone sortie de :", name, "par :", area)
	if selection_animation:
		selection_animation.stop()
