extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats
@export var is_selected: bool = false

# Références aux nœuds
@onready var visuals: Sprite2D = $Control
@onready var collision_area: Area2D = $Area2D  # Parent du CollisionShape2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var selection_box: Control = $SelectionBox

const CURSOR_FRAMES = [
	"res://Assets/UI/Cursors/select_1.png",
	"res://Assets/UI/Cursors/select_2.png",
	"res://Assets/UI/Cursors/select_3.png",
	"res://Assets/UI/Cursors/select_4.png"
]

var is_hovered: bool = false
var cursor_animation_playing: bool = false

func _ready():
	# Vérifie si la sélection est correctement configurée
	if selection_box:
		selection_box.visible = false
	else:
		print("Erreur : SelectionBox introuvable pour l'unité ", self.name)

	# Connecte les signaux de survol si le nœud collision_area est valide
	if collision_area and collision_shape:
		# Correction : Utilisation de `Callable` pour connecter les signaux
		collision_area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		collision_area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		print("Signaux de collision connectés pour :", self.name)
	else:
		print("Erreur : Area2D ou CollisionShape2D introuvable pour l'unité ", self.name)

func _on_mouse_entered():
	"""
	Appelé lorsque la souris entre dans la zone de collision.
	"""
	is_hovered = true
	print("Souris survolant l'unité :", self.name)
	start_cursor_animation()

func _on_mouse_exited():
	"""
	Appelé lorsque la souris quitte la zone de collision.
	"""
	is_hovered = false
	print("Souris quittant l'unité :", self.name)
	stop_cursor_animation()

func start_cursor_animation():
	"""
	Démarre l'animation du curseur.
	"""
	if cursor_animation_playing:
		return
	cursor_animation_playing = true
	_animate_cursor()

func stop_cursor_animation():
	"""
	Arrête l'animation du curseur.
	"""
	cursor_animation_playing = false
	var global_map = get_tree().root.get_node("GlobalMap")
	if global_map:
		global_map.set_default_cursor()

func _animate_cursor():
	"""
	Boucle d'animation du curseur.
	"""
	var frame_index = 0
	while cursor_animation_playing:
		var cursor_path = CURSOR_FRAMES[frame_index]
		var cursor_texture = load(cursor_path)
		if cursor_texture:
			Input.set_custom_mouse_cursor(cursor_texture)
		frame_index = (frame_index + 1) % CURSOR_FRAMES.size()
		await get_tree().create_timer(0.1).timeout

func set_selected(is_selected: bool):
	"""
	Définit l'état de sélection de l'unité.
	"""
	self.is_selected = is_selected
	if selection_box:
		selection_box.visible = is_selected
