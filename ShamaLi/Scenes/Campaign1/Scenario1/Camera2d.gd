extends Camera2D

# Vitesse de déplacement de la caméra
@export var move_speed: float = 400.0
# Facteur de zoom
@export var zoom_speed: float = 0.1
# Taille de la zone sensible pour le scroll par les bords (en pixels)
@export var scroll_margin: float = 10.0
# Taille de la carte (limites de la caméra)
@export var screen_limits: Vector2 = Vector2(5000, 5000)

func _ready():
	# Rend cette caméra active
	make_current()

func _process(delta: float):
	handle_movement(delta)
	scroll_with_mouse(delta)
	clamp_position()

func _input(event):
	handle_zoom(event)

# Gestion du déplacement de la caméra avec le clavier
func handle_movement(delta: float):
	var direction = Vector2.ZERO

	# Contrôles clavier pour le déplacement
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	# Appliquer le déplacement normalisé à la position de la caméra
	position += direction.normalized() * move_speed * delta

# Gestion du scroll par les bords de l'écran
func scroll_with_mouse(delta: float):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size

	var direction = Vector2.ZERO

	# Détecter si la souris est proche d'un bord horizontal
	if mouse_pos.x <= scroll_margin:
		direction.x -= 1  # Bord gauche
	elif mouse_pos.x >= viewport_size.x - scroll_margin:
		direction.x += 1  # Bord droit

	# Détecter si la souris est proche d'un bord vertical
	if mouse_pos.y <= scroll_margin:
		direction.y -= 1  # Bord supérieur
	elif mouse_pos.y >= viewport_size.y - scroll_margin:
		direction.y += 1  # Bord inférieur

	# Appliquer le déplacement
	position += direction.normalized() * move_speed * delta

# Gestion du zoom (via des actions personnalisées)
func handle_zoom(event):
	if Input.is_action_just_pressed("zoom_in"):
		zoom *= 1 - zoom_speed
	elif Input.is_action_just_pressed("zoom_out"):
		zoom *= 1 + zoom_speed

# Restreindre la caméra aux limites configurées
func clamp_position():
	position.x = clamp(position.x, 0, screen_limits.x)
	position.y = clamp(position.y, 0, screen_limits.y)
