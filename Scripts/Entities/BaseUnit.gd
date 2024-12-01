extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats  # Informations sur l'unité
@export var player_id: String = ""  # Identifiant du joueur ou de l'entité IA
@export var is_selected: bool = false  # État de sélection de l'unité

# Références aux nœuds
@onready var selection_box: Control = $SelectionBox
@onready var collision_area: Area2D = $Area2D

func _ready():
	"""
	Initialise l'unité et configure les éléments nécessaires.
	"""
	if selection_box:
		selection_box.visible = false

	if collision_area:
		collision_area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		collision_area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		collision_area.connect("input_event", Callable(self, "_on_collision_area_input_event"))

	print("BaseUnit initialisée :", name, "Position :", global_position)

func set_player_id(player_id_value: String):
	"""
	Définit l'ID du joueur propriétaire de l'unité.
	"""
	player_id = player_id_value
	print("Propriétaire défini :", player_id)

func set_selected(selected: bool):
	"""
	Définit l'état de sélection de l'unité et met à jour la visibilité de la `SelectionBox`.
	"""
	is_selected = selected
	if selection_box:
		selection_box.visible = selected

	if selected:
		print("Unité sélectionnée :", name)
	else:
		print("Unité désélectionnée :", name)

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
