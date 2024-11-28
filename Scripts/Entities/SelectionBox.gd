extends Control

# Couleur et épaisseur des bordures
@export var border_color: Color = Color(1, 0.769, 0, 1) # Jaune par défaut
@export var border_thickness: float = 2.0 # Épaisseur des bordures

# Références aux bordures (ColorRects)
@onready var top_border: ColorRect = $TopBorder
@onready var bottom_border: ColorRect = $BottomBorder
@onready var left_border: ColorRect = $LeftBorder
@onready var right_border: ColorRect = $RightBorder

func _ready():
	"""
	Initialisation : applique la couleur aux bordures et met à jour leur taille.
	"""
	_apply_border_color()
	update_borders(size)  # Met à jour les bordures selon la taille initiale

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
	Met à jour la taille et la position des bordures en fonction des dimensions de la boîte.
	"""
	# Bordure supérieure
	top_border.position = Vector2(0, 0)
	top_border.size = Vector2(rect_size.x, border_thickness)

	# Bordure inférieure
	bottom_border.position = Vector2(0, rect_size.y - border_thickness)
	bottom_border.size = Vector2(rect_size.x, border_thickness)

	# Bordure gauche
	left_border.position = Vector2(0, 0)
	left_border.size = Vector2(border_thickness, rect_size.y)

	# Bordure droite
	right_border.position = Vector2(rect_size.x - border_thickness, 0)
	right_border.size = Vector2(border_thickness, rect_size.y)

	show_borders()  # Rend visibles les bordures après mise à jour

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
