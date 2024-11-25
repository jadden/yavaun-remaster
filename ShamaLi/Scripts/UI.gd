extends Control
class_name ShamaLiUI

@onready var unit_panel = $Panel
@onready var unit_name_label = $Panel/UnitName  # Label pour le nom de l'entité
@onready var health_bar = $Panel/HealthBar  # Barre de vie
@onready var mana_bar = $Panel/ManaBar  # Barre de mana
@onready var help_panel = $HelpPanel  # Panneau d'aide
@onready var help_label = $HelpPanel/HelpLabel  # Label pour le texte d'aide

func _ready():
	# Appliquer les couleurs dynamiques aux barres
	ThemeManager.apply_bar_color(health_bar, ThemeManager.COLOR_HEALTH)
	ThemeManager.apply_bar_color(mana_bar, ThemeManager.COLOR_MANA)

# Met à jour l'interface avec les données de l'unité sélectionnée
func update_unit_info(unit: BaseUnit):
	"""
	Affiche les informations d'une unité dans l'UI.
	"""
	if not unit:
		print("Erreur : Unité invalide.")
		return

	print("Mise à jour de l'UI avec l'unité :", unit.stats.unit_name)
	unit_name_label.text = unit.stats.unit_name
	health_bar.value = unit.stats.health
	health_bar.max_value = unit.stats.health_max
	health_bar.visible = true

	mana_bar.value = unit.stats.mana
	mana_bar.max_value = unit.stats.mana_max
	mana_bar.visible = unit.stats.mana_max > 0

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
	unit_name_label.text = "Aucune entité sélectionnée"
	health_bar.value = 0
	health_bar.visible = false
	mana_bar.value = 0
	mana_bar.visible = false

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
