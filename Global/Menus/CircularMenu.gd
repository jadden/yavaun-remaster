extends Control

class_name CircularMenu

# Options principales et sous-options
@export var menu_data: Dictionary = {
	"Move": {},
	"Attack": {},
	"Cancel": {}
}

var center_position: Vector2
var is_open: bool = false

# Configuration visuelle
@export var radius: float = 100.0
@export var submenu_radius: float = 150.0
@export var button_size: Vector2 = Vector2(64, 64)

# Références aux conteneurs
@onready var option_container = $OptionContainer
@onready var submenu_container = $SubMenuContainer

func _ready():
	hide()  # Le menu est caché par défaut

func open_menu(menu_data_override: Dictionary = {}):
	# Ouvre le menu circulaire avec des options spécifiques.
	# :param menu_data_override: Si fourni, remplace les données par défaut.
	# Utilise les données par défaut ou les données spécifiques fournies
	var data = menu_data_override if menu_data_override.size() > 0 else menu_data
	_populate_menu(data, option_container, radius)
	is_open = true
	show()

func close_menu():
	# Ferme le menu circulaire.
	print("Fermeture du menu circulaire.")
	is_open = false
	hide()
	
	for child in option_container.get_children():
		child.queue_free()
	
	for child in submenu_container.get_children():
		child.queue_free()

func _populate_menu(options: Dictionary, container: Control, radius: float):
	# Remplit le menu avec des options.
	var angle_step = 360.0 / max(1, options.size())
	var current_angle = 0.0

	for option_name in options.keys():
		var button = TextureButton.new()
		button.name = option_name
		button.custom_minimum_size = button_size  # Configure la taille minimale
		button.position = Vector2(
			radius * cos(deg_to_rad(current_angle)),
			radius * sin(deg_to_rad(current_angle))
		) - button_size / 2
		container.add_child(button)

		# Ajouter un Label pour afficher le texte
		var label = Label.new()
		label.text = option_name
		label.size_flags_horizontal = Control.SIZE_FILL
		label.size_flags_vertical = Control.SIZE_FILL
		button.add_child(label)

		# Connecter l'action du bouton
		button.connect("pressed", Callable(self, "_on_option_pressed").bind(option_name, options[option_name]))
		current_angle += angle_step

func _on_option_pressed(option_name: String, sub_options: Dictionary):
	# Gère la sélection d'une option.
	print("Option sélectionnée :", option_name)
	if sub_options.size() > 0:
		# Afficher le sous-menu
		submenu_container.queue_free_children()
		_populate_menu(sub_options, submenu_container, submenu_radius)
	else:
		# Exécuter l'action
		execute_action(option_name)
		close_menu()

func execute_action(action: String):
	# Exécute une action spécifique.
	print("Action exécutée :", action)

func _input(event: InputEvent):
	# Ferme le menu si l'utilisateur clique ailleurs.
	if is_open and event is InputEventMouseButton and not event.pressed:
		if not get_global_rect().has_point(event.position):
			close_menu()
