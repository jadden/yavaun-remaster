extends Control

# Couleur et épaisseur des bordures
@export var border_color: Color = Color(1, 0, 0, 1) # Rouge par défaut
@export var border_thickness: float = 2.0 # Épaisseur des bordures

@onready var top_border: ColorRect = $TopBorder
@onready var bottom_border: ColorRect = $BottomBorder
@onready var left_border: ColorRect = $LeftBorder
@onready var right_border: ColorRect = $RightBorder

func _ready():
	"""
	Initialisation : applique la couleur aux bordures et cache le rectangle.
	"""
	_apply_border_color()
	hide_borders() # Cacher les bordures au démarrage

func _apply_border_color():
	"""
	Applique la couleur définie aux quatre bordures.
	"""
	top_border.color = border_color
	bottom_border.color = border_color
	left_border.color = border_color
	right_border.color = border_color

func update_borders(rect_size: Vector2):
	"""
	Met à jour la taille et la position des bordures selon la taille du rectangle.
	"""
	top_border.position = Vector2(0, 0)
	top_border.size = Vector2(rect_size.x, border_thickness)

	bottom_border.position = Vector2(0, rect_size.y - border_thickness)
	bottom_border.size = Vector2(rect_size.x, border_thickness)

	left_border.position = Vector2(0, 0)
	left_border.size = Vector2(border_thickness, rect_size.y)

	right_border.position = Vector2(rect_size.x - border_thickness, 0)
	right_border.size = Vector2(border_thickness, rect_size.y)

	show_borders() # Rendre les bordures visibles après mise à jour

func show_borders():
	"""
	Rend visibles toutes les bordures.
	"""
	top_border.visible = true
	bottom_border.visible = true
	left_border.visible = true
	right_border.visible = true

func hide_borders():
	"""
	Cache toutes les bordures.
	"""
	top_border.visible = false
	bottom_border.visible = false
	left_border.visible = false
	right_border.visible = false
