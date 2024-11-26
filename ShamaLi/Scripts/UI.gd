extends Control
class_name ShamaLiUI

@onready var unit_panel = $Panel
@onready var unit_name_label = $Panel/UnitName  # Label pour le nom de l'entité
@onready var unit_image = $Panel/UnitImage
@onready var health_bar = $Panel/HealthBar  # Barre de vie
@onready var mana_bar = $Panel/ManaBar  # Barre de mana
@onready var help_panel = $HelpPanel  # Panneau d'aide
@onready var help_label = $HelpPanel/HelpLabel  # Label pour le texte d'aide

func _ready():
	unit_panel.visible = false
	pass

# Met à jour l'interface avec les données de l'unité sélectionnée
func update_unit_info(unit: BaseUnit):
	"""
	Affiche les informations d'une unité dans l'UI.
	"""
	if not unit:
		print("Erreur : Unité invalide.")
		return

	print("Mise à jour de l'UI avec l'unité :", unit.stats.unit_name)
	## PANEL
	unit_panel.visible = true
	## HEALTH
	unit_name_label.text = unit.stats.unit_name
	health_bar.value = unit.stats.health
	health_bar.max_value = unit.stats.health_max
	health_bar.visible = true
	## MANA
	mana_bar.value = unit.stats.mana
	mana_bar.max_value = unit.stats.mana_max
	mana_bar.visible = unit.stats.mana_max > 0
	
	# Mise à jour de l'image
	if unit.stats.unit_image:
		var image_node = $Panel/UnitImage  # Assurez-vous d'avoir un TextureRect ou un Sprite
		image_node.visible = true
		image_node.texture = unit.stats.unit_image
		print("Image mise à jour pour :", unit.stats.unit_name)

	# Lecture du son de sélection
	if unit.stats.unit_sound_selection_path != "":
		var sound = ResourceLoader.load(unit.stats.unit_sound_selection_path)
		if sound and sound is AudioStream:
			var audio_player = AudioStreamPlayer.new()
			audio_player.stream = sound
			add_child(audio_player)
			audio_player.play()
			audio_player.connect("finished", audio_player.queue_free)
			print("Son joué pour l'unité :", unit.stats.unit_name)
		else:
			print("Erreur : Le chemin du son de selection est invalide ou le fichier n'est pas un AudioStream :", unit.stats.unit_sound_path)

# Met à jour l'interface avec les données du bâtiment sélectionné
func update_building_info(building: BaseBuilding):
	"""
	Affiche les informations d'un bâtiment dans l'UI.
	"""
	if not building:
		print("Erreur : Bâtiment invalide.")
		return

	print("Mise à jour de l'UI avec le bâtiment :", building.building_name)
	unit_name_label.text = building.building_name
	health_bar.value = building.health
	health_bar.max_value = building.max_health
	health_bar.visible = true

	mana_bar.visible = false

# Réinitialise l'interface
func clear_ui():
	"""
	Réinitialise l'UI pour qu'aucune entité ne soit sélectionnée.
	"""
	print("Réinitialisation de l'UI.")
	unit_name_label.text = ""
	unit_panel.visible = false
	health_bar.value = 0
	health_bar.visible = false
	mana_bar.value = 0
	mana_bar.visible = false
	# Réinitialiser et cacher l'image de l'unité
	if unit_image:
		unit_image.texture = null
		unit_image.visible = false

func update_help_panel(entity_name: String):
	"""
	Affiche le HelpPanel avec le nom de l'entité survolée.
	"""
	print("Mise à jour du panneau d'aide avec :", entity_name)
	help_label.text = "Type: " + entity_name
	help_panel.visible = true

func clear_help_panel():
	"""
	Cache le HelpPanel.
	"""
	print("Réinitialisation du panneau d'aide.")
	help_panel.visible = false
