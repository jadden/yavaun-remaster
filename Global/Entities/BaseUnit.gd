extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats  # Informations sur l'unité
@export var player_id: String = ""  # Identifiant du joueur ou de l'entité IA
@export var is_selected: bool = false  # État de sélection de l'unité
@export var map_size: Vector2 = Vector2(2000, 2000)  # Taille maximale de la carte (limites)

# Références aux nœuds
@onready var selection_box: Control = $SelectionBox
@onready var selection_animation: AnimationPlayer = $SelectionBox/SelectionAnimationPlayer
@onready var area2d: Area2D = $Area2D  # Area2D pour les événements d'entrée

func _ready():
	"""
	Initialise l'unité et configure les éléments nécessaires.
	"""
	print("Initialisation de BaseUnit :", name)

	# Vérifie que le nœud SelectionBox existe
	if selection_box:
		print("SelectionBox trouvé :", selection_box.name)
		selection_box.visible = false  # Masque la boîte par défaut
	else:
		print("Erreur : SelectionBox introuvable.")

	# Vérifie que l'AnimationPlayer existe
	if selection_animation:
		print("AnimationPlayer trouvé :", selection_animation.name)
	else:
		print("Erreur : AnimationPlayer introuvable dans SelectionBox.")

	# Connecte les signaux de Area2D
	if area2d:
		print("Connexion des signaux Area2D.")
		area2d.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		area2d.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		area2d.connect("input_event", Callable(self, "_on_collision_area_input_event"))
	else:
		print("Erreur : Area2D introuvable.")

func set_player_id(player_id_value: String):
	"""
	Définit l'ID du joueur propriétaire de l'unité.
	"""
	player_id = player_id_value
	print("Propriétaire défini :", player_id)

func set_selected(selected: bool):
	"""
	Définit l'état de sélection de l'unité et joue l'animation de sélection si nécessaire.
	"""
	is_selected = selected
	if selection_box:
		selection_box.visible = selected

	if selected:
		print("Unité sélectionnée :", name)
		if selection_animation and not selection_animation.is_playing():
			selection_animation.play("Effects/PulseSelectionBox")
	else:
		print("Unité désélectionnée :", name)
		if selection_animation and selection_animation.is_playing():
			selection_animation.stop()

func _on_mouse_entered():
	"""
	Gère l'événement lorsque la souris survole l'unité.
	"""
	print("Souris survole :", name, "à la position :", global_position)

func _on_mouse_exited():
	"""
	Gère l'événement lorsque la souris quitte le survol de l'unité.
	"""
	print("Souris quitte :", name, "à la position :", global_position)

func _on_collision_area_input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	"""
	Gère les interactions utilisateur sur la zone de collision.
	"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clic gauche détecté sur :", name)
			set_selected(true)

# Gestion des limites de la carte
func move_to(target_position: Vector2):
	"""
	Déplace l'unité vers une position cible, en respectant les limites de la carte.
	"""
	var clamped_position = target_position.clamp(Vector2(0, 0), map_size)
	if clamped_position != target_position:
		print("Position ajustée aux limites :", clamped_position)
	global_position = clamped_position

func move_by(offset: Vector2):
	"""
	Déplace l'unité par un décalage donné, en respectant les limites de la carte.
	"""
	var target_position = global_position + offset
	move_to(target_position)
