extends Control

class_name CircularMenu

# Options principales et sous-options par défaut
@export var default_menu_data: Dictionary = {
	"Move": {},
	"Attack": {},
	"Cancel": {}
}

# État du menu
var is_open: bool = false

# Configuration visuelle
@export var radius: float = 100.0
@export var submenu_radius: float = 150.0
@export var button_size: Vector2 = Vector2(64, 64)

# Références aux conteneurs pour les options et sous-options
@onready var option_container: Control = $OptionContainer
@onready var submenu_container: Control = $SubMenuContainer

func _ready():
	# Le menu est caché par défaut au lancement
	hide()

####
## Ouvre le menu circulaire avec des options spécifiques ou par défaut
## :param menu_data: Dictionnaire des options à afficher
####
func open_menu(menu_data: Dictionary = {}):
	print("CircularMenu - Ouverture avec les données :", menu_data)
	_clear_container(option_container)
	_clear_container(submenu_container)
	_populate_menu(menu_data, option_container, radius)
	is_open = true
	show()

func close_menu():
	# Ferme le menu circulaire et libère les options affichées
	print("CircularMenu - Fermeture du menu.")
	is_open = false
	hide()
	_clear_container(option_container)
	_clear_container(submenu_container)

func _clear_container(container: Control):
	# Supprime tous les enfants d'un conteneur donné
	for child in container.get_children():
		child.queue_free()

####
## Remplit le menu avec les options spécifiées
## :param options: Dictionnaire des options
## :param container: Conteneur cible
## :param radius: Rayon pour positionner les options
####
func _populate_menu(options: Dictionary, container: Control, radius: float):
	var angle_step = 360.0 / max(1, options.size())
	var current_angle = 0.0

	for option_name in options.keys():
		var button = _create_button(option_name)
		button.position = Vector2(
			radius * cos(deg_to_rad(current_angle)),
			radius * sin(deg_to_rad(current_angle))
		) - button_size / 2
		container.add_child(button)
		button.connect("pressed", Callable(self, "_on_option_pressed").bind(option_name, options[option_name]))
		current_angle += angle_step

func _create_button(option_name: String) -> TextureButton:
	# Crée un bouton avec un label correspondant à l'option
	var button = TextureButton.new()
	button.name = option_name
	button.custom_minimum_size = button_size
	
	var label = Label.new()
	label.text = option_name
	label.size_flags_horizontal = Control.SIZE_FILL
	label.size_flags_vertical = Control.SIZE_FILL
	button.add_child(label)

	return button

####
## Gère la sélection d'une option
## :param option_name: Nom de l'option sélectionnée
## :param sub_options: Sous-options associées
####
func _on_option_pressed(option_name: String, sub_options: Dictionary):
	print("CircularMenu - Option sélectionnée :", option_name)
	if sub_options.size() > 0:
		print("CircularMenu - Affichage des sous-options :", sub_options)
		_clear_container(submenu_container)
		_populate_menu(sub_options, submenu_container, submenu_radius)
	else:
		execute_action(option_name)
		close_menu()

func execute_action(action: String):
	# Exécute une action spécifique en fonction de l'option sélectionnée
	print("CircularMenu - Action exécutée :", action)

func _input(event: InputEvent):
	# Ferme le menu si un clic est détecté en dehors de celui-ci
	if is_open and event is InputEventMouseButton and not event.pressed:
		if not get_global_rect().has_point(event.position):
			close_menu()
