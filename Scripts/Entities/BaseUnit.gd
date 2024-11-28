extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats
@export var is_selected: bool = false

# Références aux nœuds
@onready var selection_box: Control = $SelectionBox

func _ready():
	"""
	Initialisation de l'unité.
	"""
	if selection_box:
		selection_box.visible = false
	else:
		print("Erreur : SelectionBox introuvable pour l'unité", name)

func set_selected(selected: bool):
	"""
	Définit l'état de sélection de l'unité.
	"""
	is_selected = selected
	if selection_box:
		selection_box.visible = selected
	print("Unité", name, "sélectionnée :", selected)
