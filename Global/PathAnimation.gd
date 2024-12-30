extends Node2D

# Images pour l'animation
var frames: Array = []
var frame_index: int = 0
var timer: Timer = null

# Durée entre les frames
@export var frame_time: float = 0.1

func start_animation(position: Vector2, frames_to_use: Array):
	"""
	Démarre l'animation avec les frames données.
	"""
	self.position = position
	frames = frames_to_use
	frame_index = 0

	# Ajouter un Timer pour gérer l'animation
	timer = Timer.new()
	timer.wait_time = frame_time
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_next_frame"))
	add_child(timer)

	# Démarrer le Timer
	timer.start()
	_show_frame()

func _next_frame():
	"""
	Passer à la frame suivante de l'animation.
	"""
	frame_index += 1
	if frame_index >= frames.size():
		# Animation terminée
		queue_free()
		return
	_show_frame()

func _show_frame():
	"""
	Affiche la frame actuelle de l'animation.
	"""
	# Supprimer les anciens enfants
	for child in get_children():
		child.queue_free()

	# Ajouter la nouvelle frame
	var texture = load(frames[frame_index])
	if texture:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.position = Vector2.ZERO
		add_child(sprite)
