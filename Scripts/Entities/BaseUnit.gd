extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats  # Informations sur l'unité, telles que la santé, le mana, etc.
@export var is_selected: bool = false  # État de sélection de l'unité

# Références aux nœuds
@onready var selection_box: Control = $SelectionBox  # Indique visuellement la sélection
@onready var collision_area: Area2D = $Area2D  # Zone de collision pour la détection des interactions
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D  # Forme de collision de l'unité
@onready var visuals: Sprite2D = $Sprite2D  # Représentation visuelle de l'unité (ex. : sprite)

func _ready():
	"""
	Initialise l'unité et configure les éléments nécessaires.
	"""
	# Vérifie et masque la sélection par défaut
	if selection_box:
		selection_box.visible = false
		print("SelectionBox masqué pour l'unité :", name)
	else:
		print("Erreur : SelectionBox introuvable pour l'unité :", name)

	# Configure la détection de collision pour les événements souris
	if collision_area:
		collision_area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		collision_area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		collision_area.connect("input_event", Callable(self, "_on_collision_area_input_event"))
		print("Signaux de collision connectés pour :", name)
	else:
		print("Erreur : Area2D introuvable pour l'unité :", name)

	# Vérifie si le CollisionShape2D est correctement configuré
	if collision_shape:
		if collision_shape.disabled:
			print("Erreur : CollisionShape2D désactivé pour l'unité :", name)
		else:
			print("CollisionShape2D configuré pour :", name)
	else:
		print("Erreur : CollisionShape2D introuvable pour l'unité :", name)

func set_selected(selected: bool):
	"""
	Définit l'état de sélection de l'unité et met à jour le `SelectionBox`.
	"""
	is_selected = selected
	if selection_box:
		selection_box.visible = selected
		if selected:
			print("Unité sélectionnée :", name)
			_play_selection_animation()
		else:
			print("Unité désélectionnée :", name)
	else:
		print("Erreur : SelectionBox non trouvé pour l'unité :", name)

func _on_mouse_entered():
	"""
	Appelé lorsque la souris survole l'unité.
	"""
	print("Souris survole :", name)
	# Vous pouvez ajouter ici un effet visuel ou afficher des infos contextuelles.

func _on_mouse_exited():
	"""
	Appelé lorsque la souris quitte le survol de l'unité.
	"""
	print("Souris quitte :", name)
	# Supprimez les effets visuels ou infos contextuelles si nécessaire.

func _on_collision_area_input_event(viewport, event: InputEvent, shape_idx: int):
	"""
	Gère les événements d'entrée sur la zone de collision (clic gauche, clic droit, etc.).
	"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Unité cliquée :", name)
			set_selected(true)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Clic droit sur :", name)
			# Ajoutez une logique personnalisée pour le clic droit, comme déplacer l'unité.

func _play_selection_animation():
	"""
	Joue l'animation de sélection si un `AnimationPlayer` est présent dans le `SelectionBox`.
	"""
	if selection_box:
		var animation_player = selection_box.get_node_or_null("SelectionAnimationPlayer")
		if animation_player and animation_player is AnimationPlayer:
			animation_player.play("Effects/PulseSelectionBox")
			print("Animation de sélection jouée pour :", name)
		else:
			print("Erreur : AnimationPlayer introuvable ou non configuré dans SelectionBox.")
