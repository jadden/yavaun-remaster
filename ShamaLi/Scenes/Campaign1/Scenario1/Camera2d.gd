extends Camera2D

# Vitesse de déplacement de la caméra
@export var move_speed: float = 400.0
# Facteur de zoom
@export var zoom_speed: float = 0.1
# Limites de mouvement de la caméra
@export var limit_left: float = 0.0
@export var limit_right: float = 5000.0
@export var limit_top: float = 0.0
@export var limit_bottom: float = 5000.0

func _ready():
	# Rend cette caméra active
	make_current()

func _process(delta: float):
	handle_movement(delta)
	clamp_position()

func _input(event):
	handle_zoom(event)

# Gestion du déplacement de la caméra
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

# Gestion du zoom (via la molette ou des touches)
func handle_zoom(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.WHEEL_UP and event.pressed:
		zoom *= 1 - zoom_speed
	elif event is InputEventMouseButton and event.button_index == MouseButton.WHEEL_DOWN and event.pressed:
		zoom *= 1 + zoom_speed

# Restreindre la caméra aux limites de la carte
func clamp_position():
	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)
