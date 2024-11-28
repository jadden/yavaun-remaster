extends Control
class_name ShamaLiUI

# Références aux éléments de l'interface
@onready var unit_panel = $Panel  # Panneau principal pour afficher les informations d'une unité
@onready var unit_name_label = $Panel/UnitName  # Label pour afficher le nom de l'entité
@onready var unit_image = $Panel/UnitImage  # Image de l'entité ou du groupe sélectionné
@onready var health_bar = $Panel/HealthBar  # Barre de vie pour une unité unique
@onready var mana_bar = $Panel/ManaBar  # Barre de mana pour une unité unique
@onready var help_panel = $HelpPanel  # Panneau d'aide pour afficher les infos contextuelles
@onready var help_label = $HelpPanel/HelpLabel  # Label pour afficher le texte d'aide contextuelle

# Image de groupe spécifique à la race
@export var group_name: String = "Groupe Shama'Li"
@export var group_image_path: String = "res://ShamaLi/Assets/Portraits/group.png"

func _ready():
	"""
	Initialise l'interface utilisateur en masquant les panneaux au démarrage.
	"""
	unit_panel.visible = false
	help_panel.visible = false
	print("ShamaLiUI initialisé. Panneaux masqués.")

# Met à jour l'interface avec les données des unités sélectionnées
func update_multiple_units_info(units: Array):
	"""
	Affiche les informations lorsque plusieurs unités sont sélectionnées.
	"""
	if units.is_empty():
		print("Erreur : Aucune unité sélectionnée.")
		clear_ui()
		return

	print("Mise à jour de l'UI pour plusieurs unités. Nombre d'unités :", units.size())

	# Définir un nom générique
	unit_name_label.text = group_name

	# Charger l'image de groupe
	var group_image = ResourceLoader.load(group_image_path)
	if group_image and group_image is Texture2D:
		unit_image.visible = true
		unit_image.texture = group_image
		print("Image de groupe affichée.")
	else:
		unit_image.visible = false
		print("Erreur : Image de groupe introuvable ou invalide.")

	# Cacher les barres de vie et de mana
	health_bar.visible = false
	mana_bar.visible = false

	# Jouer les sons de sélection des unités
	_play_multiple_selection_sounds(units)

	# Afficher le panneau principal
	unit_panel.visible = true

func _play_multiple_selection_sounds(units: Array):
	"""
	Joue les sons des unités sélectionnées simultanément.
	"""
	for unit in units:
		if unit.stats.unit_sound_selection_path:
			var sound = ResourceLoader.load(unit.stats.unit_sound_selection_path)
			if sound and sound is AudioStream:
				var audio_player = AudioStreamPlayer.new()
				audio_player.stream = sound
				add_child(audio_player)
				audio_player.play()
				audio_player.connect("finished", audio_player.queue_free)
				print("Son joué pour l'unité :", unit.stats.unit_name)
			else:
				print("Erreur : Le chemin du son est invalide ou le fichier n'est pas un AudioStream :", unit.stats.unit_sound_selection_path)

# Met à jour l'interface avec les données de l'unité sélectionnée
func update_unit_info(unit: BaseUnit):
	"""
	Affiche les informations d'une unité dans l'UI.
	"""
	if not unit:
		print("Erreur : Unité invalide.")
		return

	clear_ui()

	print("Mise à jour de l'UI avec l'unité :", unit.stats.unit_name)

	# Mise à jour des informations de l'unité
	unit_name_label.text = unit.stats.unit_name
	health_bar.max_value = unit.stats.health_max  # Correction : Mettre le max avant la valeur
	health_bar.value = unit.stats.health
	health_bar.visible = true

	# Mise à jour du panneau principal
	unit_panel.visible = true

	mana_bar.max_value = unit.stats.mana_max  # Correction similaire pour la mana
	mana_bar.value = unit.stats.mana
	mana_bar.visible = unit.stats.mana_max > 0  # Cache la barre de mana si elle n'est pas utilisée

	# Mise à jour de l'image
	if unit.stats.unit_image:
		unit_image.visible = true
		unit_image.texture = unit.stats.unit_image
		print("Image mise à jour pour :", unit.stats.unit_name)
	else:
		print("Aucune image trouvée pour :", unit.stats.unit_name)
		unit_image.visible = false

	# Lecture du son de sélection
	if unit.stats.unit_sound_selection_path:
		_play_selection_sound(unit.stats.unit_sound_selection_path)

# Joue le son de sélection d'une unité
func _play_selection_sound(sound_path: String):
	"""
	Joue le son défini dans le chemin donné.
	"""
	var sound = ResourceLoader.load(sound_path)
	if sound and sound is AudioStream:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = sound
		add_child(audio_player)
		audio_player.play()
		audio_player.connect("finished", audio_player.queue_free)
		print("Son joué :", sound_path)
	else:
		print("Erreur : Le chemin du son est invalide ou le fichier n'est pas un AudioStream :", sound_path)

# Réinitialise l'interface
func clear_ui():
	"""
	Réinitialise l'UI pour qu'aucune entité ne soit sélectionnée.
	"""
	print("Réinitialisation de l'UI.")
	unit_panel.visible = false
	unit_name_label.text = ""
	health_bar.value = 0
	health_bar.visible = false
	mana_bar.value = 0
	mana_bar.visible = false
	unit_image.texture = null
	unit_image.visible = false

# Met à jour le panneau d'aide contextuel
func update_help_panel(entity_name: String):
	"""
	Affiche des informations contextuelles sur l'entité survolée.
	"""
	if not entity_name:
		print("Erreur : Aucun nom d'entité fourni pour le panneau d'aide.")
		clear_help_panel()
		return

	print("Mise à jour du panneau d'aide avec :", entity_name)
	help_label.text = "Type: " + entity_name
	help_panel.visible = true

# Cache le panneau d'aide contextuel
func clear_help_panel():
	"""
	Cacher le panneau d'aide contextuel.
	"""
	print("Réinitialisation du panneau d'aide.")
	help_panel.visible = false
	help_label.text = ""
