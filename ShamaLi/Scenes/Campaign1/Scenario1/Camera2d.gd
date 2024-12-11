extends Camera2D

# Vitesse de déplacement de la caméra
@export var move_speed: float = 400.0
@export var zoom_speed: float = 0.1
@export var scroll_margin: float = 10.0
@export var screen_limits: Vector2 = Vector2(7000, 7000)

func _ready():
	"""
	Rend cette caméra active au démarrage.
	"""
	make_current()
	print("Camera active:", is_current())

func _process(delta: float):
	handle_movement(delta)
	scroll_with_mouse(delta)
	clamp_position()

func _input(event):
	handle_zoom(event)

func handle_movement(delta: float):
	"""
	Gère le déplacement de la caméra via les touches directionnelles.
	"""
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	position += direction.normalized() * move_speed * delta

func scroll_with_mouse(delta: float):
	"""
	Gère le déplacement de la caméra avec les bords de l'écran.
	"""
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var direction = Vector2.ZERO
	if mouse_pos.x <= scroll_margin:
		direction.x -= 1
	elif mouse_pos.x >= viewport_size.x - scroll_margin:
		direction.x += 1
	if mouse_pos.y <= scroll_margin:
		direction.y -= 1
	elif mouse_pos.y >= viewport_size.y - scroll_margin:
		direction.y += 1
	position += direction.normalized() * move_speed * delta

func handle_zoom(event):
	"""
	Gère le zoom de la caméra avec des actions personnalisées.
	"""
	if Input.is_action_just_pressed("zoom_in"):
		zoom *= 1 - zoom_speed
	elif Input.is_action_just_pressed("zoom_out"):
		zoom *= 1 + zoom_speed

func clamp_position():
	"""
	Restreint la caméra aux limites configurées.
	"""
	position.x = clamp(position.x, -screen_limits.x, screen_limits.x)
	position.y = clamp(position.y, -screen_limits.y, screen_limits.y)

func viewport_to_global(viewport_position: Vector2) -> Vector2:
	"""
	Convertit une position dans le viewport en position globale (monde).
	"""
	return position + (viewport_position / zoom)

func global_to_viewport(global_position: Vector2) -> Vector2:
	"""
	Convertit une position globale (monde) en position dans le viewport.
	"""
	return (global_position - position) * zoom
