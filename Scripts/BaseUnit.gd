extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats
@export var is_selected: bool = false

# Références aux nœuds internes
@onready var visuals: Sprite2D = $Control  # Rendu visuel
@onready var collision_area: Area2D = $CollisionArea2D  # Zone de collision pour la détection du survol
@onready var selection_box: Control = $CollisionArea2D/SelectionBox  # Boîte de sélection

# Curseurs pour l'animation
const CURSOR_FRAMES = [
	"res://Assets/UI/Cursors/select_1.png",
	"res://Assets/UI/Cursors/select_2.png",
	"res://Assets/UI/Cursors/select_3.png",
	"res://Assets/UI/Cursors/select_4.png"
]

var is_hovered: bool = false  # Indique si l'unité est survolée
var cursor_animation_playing: bool = false  # Indique si l'animation du curseur est en cours

func _ready():
	# Masquer la boîte de sélection par défaut
	if selection_box:
		selection_box.visible = false
	else:
		print("Erreur : SelectionBox introuvable pour l'unité ", self.name)

	# Connecter les signaux `mouse_entered` et `mouse_exited` depuis `collision_area`
	if collision_area:
		collision_area.mouse_entered.connect(_on_mouse_entered)
		collision_area.mouse_exited.connect(_on_mouse_exited)
	else:
		print("Erreur : CollisionArea2D introuvable pour l'unité ", self.name)

func _on_mouse_entered():
	is_hovered = true
	# Lancer l'animation du curseur
	start_cursor_animation()

func _on_mouse_exited():
	is_hovered = false
	# Arrêter l'animation du curseur et remettre le curseur par défaut
	stop_cursor_animation()

func start_cursor_animation():
	if cursor_animation_playing:
		return  # Empêche le démarrage de plusieurs animations simultanées

	cursor_animation_playing = true
	# Lancer l'animation du curseur
	_animate_cursor()

func stop_cursor_animation():
	cursor_animation_playing = false
	var global_map = get_tree().root.get_node("GlobalMap")  # Chemin relatif
	if global_map:
		global_map.set_default_cursor()
	else:
		print("Erreur : GlobalMap introuvable.")

func _animate_cursor():
	var frame_index = 0
	while cursor_animation_playing:
		var cursor_path = CURSOR_FRAMES[frame_index]
		var cursor_texture = load(cursor_path)
		if cursor_texture:
			Input.set_custom_mouse_cursor(cursor_texture)
		else:
			print("Erreur : Impossible de charger le curseur ", cursor_path)

		# Passer à l'image suivante (boucle sur les frames)
		frame_index = (frame_index + 1) % CURSOR_FRAMES.size()

		# Attendre un court moment avant de passer à la prochaine image
		await get_tree().create_timer(0.1).timeout  # 0.1 seconde entre chaque frame

func set_selected(is_selected: bool):
	if selection_box:
		selection_box.visible = is_selected
	else:
		print("Erreur : La SelectionBox est manquante pour ", self.name)

# Optionnel : Ajouter une fonction pour gérer les déplacements
func move_to(target_position: Vector2):
	# Implémentez la logique de déplacement ici
	# Par exemple, utiliser un chemin ou déplacer progressivement l'unité
	print(self.name, "se déplace vers", target_position)
	# Exemple simple de déplacement instantané :
	global_position = target_position
