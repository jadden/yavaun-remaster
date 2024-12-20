extends Control
class_name ShamaLiUI

# Signal émis lorsque l'UI est prête
signal ui_ready

# Références aux éléments de l'interface
@onready var leader_panel = $Panel/LeaderPanel
@onready var leader_name_label = $Panel/LeaderPanel/LeaderName
@onready var leader_health_bar = $Panel/LeaderPanel/LeaderHealth
@onready var resource_score_label = $Panel/RessourcesScore
@onready var unit_panel = $Panel/UnitPanel
@onready var unit_name_label = $Panel/UnitPanel/UnitName
@onready var unit_image = $Panel/UnitPanel/UnitImage
@onready var health_bar = $Panel/UnitPanel/HealthBar
@onready var mana_bar = $Panel/UnitPanel/ManaBar
@onready var help_panel = $HelpPanel
@onready var help_label = $HelpPanel/HelpLabel
@onready var minimap = $Panel/MiniMap

# Variables dynamiques
var leader_name: String = ""
var leader_health: int = 0
var resource_score: int = 0
var leader_unit: BaseUnit = null  # Référence au leader
var group_name: String = "Tribu Shama'Li"
var group_image_path: String = "res://ShamaLi/Assets/Portraits/group.png"

func _ready():
	"""
	Initialise l'interface utilisateur.
	"""
	reset_ui()
	emit_signal("ui_ready")

func reset_ui():
	"""
	Remet à zéro l'intégralité de l'interface utilisateur.
	"""
	clear_leader_panel()
	clear_unit_panel()
	clear_help_panel()

func update_leader_data(leader: BaseUnit, resource_data: int):
	"""
	Met à jour les informations du leader (nom, santé, ressources).
	"""
	if leader:
		leader_unit = leader
		leader_name = leader.stats.unit_name
		leader_health = leader.stats.health
		leader_health_bar.max_value = leader.stats.health_max
		leader_health_bar.value = leader_health
		leader_name_label.text = leader_name
	else:
		clear_leader_panel()

	resource_score = resource_data
	resource_score_label.text = str(resource_score)

func update_unit_info(unit: BaseUnit):
	"""
	Met à jour le panneau d'informations pour une unité sélectionnée.
	"""
	if not unit:
		clear_unit_panel()
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

func update_generic_enemy_info(faction: String, portrait_path: String):
	"""
	Met à jour le panneau pour une unité ennemie avec portrait générique et nom de faction.
	"""
	unit_name_label.text = faction
	var texture = ResourceLoader.load(portrait_path)
	if texture and texture is Texture2D:
		unit_image.texture = texture
		unit_image.visible = true
	else:
		unit_image.visible = false

	health_bar.visible = true
	mana_bar.visible = false
	unit_panel.visible = true

func update_multiple_units_info(units: Array):
	"""
	Met à jour le panneau lorsque plusieurs unités sont sélectionnées.
	"""
	if units.is_empty():
		clear_unit_panel()
		return

	unit_name_label.text = group_name
	var group_image = ResourceLoader.load(group_image_path)
	if group_image and group_image is Texture2D:
		unit_image.texture = group_image
		unit_image.visible = true
	else:
		unit_image.visible = false

	health_bar.visible = false
	mana_bar.visible = false
	unit_panel.visible = true

func clear_leader_panel():
	"""
	Réinitialise les informations du leader.
	"""
	leader_name_label.text = "Inconnu"
	leader_health_bar.value = 0
	leader_health_bar.max_value = 100
	resource_score_label.text = "0"

func clear_unit_panel():
	"""
	Réinitialise les informations des unités sélectionnées.
	"""
	unit_panel.visible = false
	unit_name_label.text = ""
	health_bar.visible = false
	mana_bar.visible = false
	unit_image.texture = null
	unit_image.visible = false

func update_unit_health(unit: BaseUnit, new_health: int):
	"""
	Met à jour la santé d'une unité sélectionnée.
	"""
	if not unit or not unit_panel.visible:
		return

	if unit.stats and unit.stats.unit_name == unit_name_label.text:
		health_bar.value = new_health

func clear_help_panel():
	"""
	Réinitialise le panneau d'aide.
	"""
	help_panel.visible = false
	help_label.text = ""
