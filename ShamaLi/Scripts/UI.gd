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
@onready var right_ui = $VBoxContainer/RightUI  # Zone interactive droite
@onready var bottom_bar = $VBoxContainer/BottomBar  # Zone interactive inférieure

# Image de groupe spécifique à la race
@export var group_name: String = "Groupe Shama'Li"
@export var group_image_path: String = "res://ShamaLi/Assets/Portraits/group.png"

# Curseurs
var race_cursor: Texture  # Curseur spécifique à la race
var map_cursor: Texture = preload("res://Assets/UI/Cursors/select_1.png")

func _ready():
	"""
	Initialise l'interface utilisateur en masquant les panneaux et connecte les signaux.
	"""
	unit_panel.visible = false
	help_panel.visible = false
	print("ShamaLiUI initialisé. Panneaux masqués.")

	# Connecter les événements de survol pour les zones interactives
	if right_ui:
		right_ui.connect("mouse_entered", Callable(self, "_on_mouse_entered_right_ui"))
		right_ui.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	if bottom_bar:
		bottom_bar.connect("mouse_entered", Callable(self, "_on_mouse_entered_bottom_bar"))
		bottom_bar.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

# Gestion des curseurs
func set_cursors(race_cursor_texture: Texture, map_cursor_texture: Texture):
	"""
	Définit les curseurs spécifiques à la race et à la carte.
	"""
	race_cursor = race_cursor_texture
	map_cursor = map_cursor
	print("Curseurs configurés : race =", race_cursor, ", carte =", map_cursor)

func _on_mouse_entered_right_ui():
	"""
	Change le curseur pour celui de la race lorsqu'on survole la RightUI.
	"""
	_set_cursor(race_cursor)
	print("Curseur de race appliqué (RightUI).")

func _on_mouse_entered_bottom_bar():
	"""
	Change le curseur pour celui de la race lorsqu'on survole la BottomBar.
	"""
	_set_cursor(race_cursor)
	print("Curseur de race appliqué (BottomBar).")

func _on_mouse_exited():
	"""
	Change le curseur pour celui de la carte lorsqu'on quitte les zones interactives.
	"""
	_set_cursor(map_cursor)
	print("Curseur de carte rétabli.")

func _set_cursor(cursor: Texture):
	"""
	Applique dynamiquement le curseur donné.
	"""
	if cursor:
		Input.set_custom_mouse_cursor(cursor)
	else:
		print("Erreur : Curseur non défini.")

# Gestion des unités sélectionnées
func update_multiple_units_info(units: Array):
	"""
	Affiche les informations pour plusieurs unités sélectionnées.
	"""
	if units.is_empty():
		print("Erreur : Aucune unité sélectionnée.")
		clear_ui()
		return

	print("Mise à jour de l'UI pour plusieurs unités. Nombre d'unités :", units.size())

	# Mettre un nom générique
	unit_name_label.text = group_name

	# Charger et afficher l'image de groupe
	var group_image = ResourceLoader.load(group_image_path)
	if group_image and group_image is Texture2D:
		unit_image.visible = true
		unit_image.texture = group_image
		print("Image de groupe affichée.")
	else:
		unit_image.visible = false
		print("Erreur : Image de groupe introuvable ou invalide.")

	# Masquer les barres de vie et de mana
	health_bar.visible = false
	mana_bar.visible = false

	# Jouer les sons de sélection
	_play_multiple_selection_sounds(units)

	# Afficher le panneau principal
	unit_panel.visible = true

func update_unit_info(unit: BaseUnit):
	"""
	Affiche les informations d'une unité sélectionnée.
	"""
	if not unit:
		print("Erreur : Unité invalide.")
		return

	clear_ui()

	print("Mise à jour de l'UI avec l'unité :", unit.stats.unit_name)

	# Mise à jour des informations de l'unité
	unit_name_label.text = unit.stats.unit_name
	health_bar.max_value = unit.stats.health_max  # Fixer la limite avant de mettre la valeur
	health_bar.value = unit.stats.health
	health_bar.visible = true

	# Mise à jour de l'image
	if unit.stats.unit_image:
		unit_image.visible = true
		unit_image.texture = unit.stats.unit_image
		print("Image mise à jour pour :", unit.stats.unit_name)
	else:
		unit_image.visible = false
		print("Aucune image trouvée pour :", unit.stats.unit_name)

	# Mise à jour de la mana
	mana_bar.max_value = unit.stats.mana_max
	mana_bar.value = unit.stats.mana
	mana_bar.visible = unit.stats.mana_max > 0

	# Lecture du son de sélection
	if unit.stats.unit_sound_selection_path:
		_play_selection_sound(unit.stats.unit_sound_selection_path)

	# Afficher le panneau principal
	unit_panel.visible = true

# Gestion des sons
func _play_multiple_selection_sounds(units: Array):
	"""
	Joue les sons pour plusieurs unités sélectionnées.
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
				print("Erreur : Son invalide pour l'unité :", unit.stats.unit_name)

func _play_selection_sound(sound_path: String):
	"""
	Joue le son de sélection pour une unité unique.
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
		print("Erreur : Son introuvable :", sound_path)

# Réinitialisation
func clear_ui():
	"""
	Réinitialise l'interface utilisateur.
	"""
	unit_panel.visible = false
	unit_name_label.text = ""
	health_bar.value = 0
	health_bar.visible = false
	mana_bar.value = 0
	mana_bar.visible = false
	unit_image.texture = null
	unit_image.visible = false
	print("UI réinitialisée.")

func update_help_panel(entity_name: String):
	"""
	Affiche le panneau d'aide avec des informations contextuelles.
	"""
	if not entity_name:
		print("Erreur : Aucun nom d'entité fourni.")
		clear_help_panel()
		return

	help_label.text = "Type: " + entity_name
	help_panel.visible = true
	print("Panneau d'aide mis à jour avec :", entity_name)

func clear_help_panel():
	"""
	Cacher le panneau d'aide.
	"""
	help_panel.visible = false
	help_label.text = ""
	print("Panneau d'aide réinitialisé.")
