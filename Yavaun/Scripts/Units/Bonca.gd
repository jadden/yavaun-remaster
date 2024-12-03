extends BaseUnit

# Variables d'animation et de mouvement
@export var move_speed: float = 50.0  # Vitesse de déplacement
@export var wander_radius: float = 300.0  # Rayon maximal d'errance
@export var idle_time_range: Vector2 = Vector2(1.0, 3.0)  # Temps d'inactivité entre les mouvements (min, max)

# Point de départ
var start_position: Vector2 = Vector2.ZERO
var current_direction: Vector2 = Vector2.ZERO

# Références aux composants graphiques
@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $Sprite2D  # Sprite qui doit être masqué lors de l'animation

func _ready() -> void:
	"""
	Initialisation de l'entité Bonca.
	"""
	super._ready()  # Appelle la méthode `_ready()` de BaseUnit
	start_position = global_position  # Définit la position de départ
	print("Bonca _ready() appelé.")
	_idle()  # Commence en mode inactif

func _idle() -> void:
	"""
	Met le Bonca en mode inactif pendant un temps aléatoire.
	"""
	animator.stop()  # Arrête l'animation en cours
	animator.frame = 0  # Optionnel : repositionne l'animation à son état initial
	var idle_time = randf_range(idle_time_range.x, idle_time_range.y)
	print("Bonca en mode idle pour :", idle_time, "secondes.")
	get_tree().create_timer(idle_time).connect("timeout", Callable(self, "_choose_new_direction"))

func _choose_new_direction() -> void:
	"""
	Définit une nouvelle direction aléatoire pour errer.
	"""
	current_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var new_position = start_position + current_direction * wander_radius

	print("Bonca choisit une nouvelle direction vers :", new_position)

	# Vérifie que la nouvelle position est dans les limites
	if new_position.distance_to(start_position) <= wander_radius:
		_move_to(new_position)
	else:
		_idle()

func _move_to(target_position: Vector2) -> void:
	"""
	Déplace le Bonca vers une position cible.
	"""
	var direction = (target_position - global_position).normalized()
	current_direction = direction
	_play_walk_animation(direction)

	print("Bonca se déplace vers :", target_position)

	var travel_time = global_position.distance_to(target_position) / move_speed
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, travel_time)
	tween.connect("finished", Callable(self, "_idle"))

func _play_walk_animation(direction: Vector2) -> void:
	"""
	Joue l'animation de marche en fonction de la direction.
	"""
	_hide_sprite()  # Masque le Sprite2D lors de l'animation
	var direction_name = _get_direction_name(direction)
	if direction_name != "":
		animator.flip_h = direction.x < 0  # Flip horizontal si la direction est gauche
		animator.play("walk_" + direction_name)
		print("Bonca joue l'animation :", "walk_" + direction_name)

func _get_direction_name(direction: Vector2) -> String:
	"""
	Renvoie le nom de la direction en fonction du vecteur de direction.
	"""
	if abs(direction.x) > abs(direction.y):  # Prédominance horizontale
		return "rightdown" if direction.x > 0 else "rightdown"  # Flip géré ailleurs
	elif abs(direction.y) > abs(direction.x):  # Prédominance verticale
		return "down" if direction.y > 0 else "up"
	else:  # Diagonales
		if direction.x > 0:
			return "rightup" if direction.y < 0 else "rightdown"
		else:
			return "rightup" if direction.y < 0 else "rightdown"

func _hide_sprite():
	"""
	Masque le Sprite2D lorsque l'animation est jouée.
	"""
	if sprite:
		sprite.visible = false
		print("Sprite2D masqué.")

func _show_sprite():
	"""
	Affiche le Sprite2D lorsque le Bonca est idle.
	"""
	if sprite:
		sprite.visible = true
		print("Sprite2D affiché.")
