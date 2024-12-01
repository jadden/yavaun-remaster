extends Control
class_name ShamaLiUI

# Signal émis lorsque l'UI est prête
signal ui_ready

# Références aux éléments de l'interface
@onready var unit_panel = $Panel  # Panneau principal pour afficher les informations d'une unité
@onready var unit_name_label = $Panel/UnitName  # Label pour afficher le nom de l'entité
@onready var unit_image = $Panel/UnitImage  # Image de l'entité ou du groupe sélectionné
@onready var health_bar = $Panel/HealthBar  # Barre de vie pour une unité unique
@onready var mana_bar = $Panel/ManaBar  # Barre de mana pour une unité unique
@onready var leader_name_label = $Panel/LeaderName  # Nom du leader
@onready var leader_health_bar = $Panel/LeaderHealth  # Barre de vie du leader
@onready var resource_score_label = $Panel/RessourcesScore  # Score de ressources
@onready var minimap = $Panel/MiniMap  # Placeholder pour la future minimap
@onready var help_panel = $HelpPanel  # Panneau d'aide pour afficher les infos contextuelles
@onready var help_label = $HelpPanel/HelpLabel  # Label pour afficher le texte d'aide contextuelle

# Variables dynamiques
var leader_name: String = ""
var leader_health: int = 0
var resource_score: int = 0
var group_name: String = "Groupe Shama'Li"
var group_image_path: String = "res://ShamaLi/Assets/Portraits/group.png"

func _ready():
	"""
	Initialise l'interface utilisateur et émet le signal `ui_ready`.
	"""
	clear_ui()
	leader_name_label.text = "Inconnu"
	leader_health_bar.max_value = 100
	leader_health_bar.value = 0
	resource_score_label.text = "0"
	unit_panel.visible = false
	help_panel.visible = false
	print("Interface Raciale ShamaLiUI initialisée.")

	# Émettre le signal pour notifier que l'UI est prête
	emit_signal("ui_ready")

func update_clan_data(clan_data: Dictionary):
	"""
	Met à jour les informations affichées pour le clan actuel.
	"""
	if clan_data.has("leader_name"):
		leader_name = clan_data["leader_name"]
		leader_name_label.text = leader_name

	if clan_data.has("leader_health"):
		leader_health = clan_data["leader_health"]
		leader_health_bar.value = leader_health
		leader_health_bar.visible = true

	if clan_data.has("resource_score"):
		resource_score = clan_data["resource_score"]
		resource_score_label.text = str(resource_score)

	print("Interface mise à jour avec les données du clan :", clan_data)

func update_multiple_units_info(units: Array):
	"""
	Affiche les informations lorsque plusieurs unités sont sélectionnées.
	"""
	if units.is_empty():
		clear_ui()
		return

	print("Mise à jour pour plusieurs unités : ", units.size())
	unit_name_label.text = group_name

	# Charger l'image de groupe
	var group_image = ResourceLoader.load(group_image_path)
	if group_image and group_image is Texture2D:
		unit_image.visible = true
		unit_image.texture = group_image
	else:
		unit_image.visible = false

	health_bar.visible = false
	mana_bar.visible = false
	unit_panel.visible = true

func update_unit_info(unit: BaseUnit):
	"""
	Affiche les informations pour une unité unique.
	"""
	if not unit:
		print("Erreur : Unité invalide.")
		clear_ui()
		return

	unit_name_label.text = unit.stats.unit_name
	health_bar.max_value = unit.stats.health_max
	health_bar.value = unit.stats.health
	health_bar.visible = true
	mana_bar.max_value = unit.stats.mana_max
	mana_bar.value = unit.stats.mana
	mana_bar.visible = unit.stats.mana_max > 0

	if unit.stats.unit_image:
		unit_image.texture = unit.stats.unit_image
		unit_image.visible = true
	else:
		unit_image.visible = false

	unit_panel.visible = true

func clear_ui():
	"""
	Réinitialise l'interface utilisateur.
	"""
	unit_panel.visible = false
	unit_name_label.text = ""
	health_bar.visible = false
	mana_bar.visible = false
	unit_image.texture = null
	unit_image.visible = false
	leader_name_label.text = "Inconnu"
	leader_health_bar.value = 0
	help_panel.visible = false
	help_label.text = ""
	print("Interface réinitialisée.")

func update_leader_health(new_health: int):
	"""
	Met à jour la santé du leader.
	"""
	leader_health = new_health
	leader_health_bar.value = leader_health
	print("Santé du leader mise à jour :", new_health)

func update_resource_score(new_score: int):
	"""
	Met à jour le score de ressources.
	"""
	resource_score = new_score
	resource_score_label.text = str(new_score)
	print("Score de ressources mis à jour :", new_score)

func update_help_panel(entity_name: String):
	"""
	Affiche des informations contextuelles sur une entité.
	"""
	if not entity_name:
		clear_help_panel()
		return

	help_label.text = "Type: " + entity_name
	help_panel.visible = true

func clear_help_panel():
	"""
	Réinitialise le panneau d'aide.
	"""
	help_panel.visible = false
	help_label.text = ""
