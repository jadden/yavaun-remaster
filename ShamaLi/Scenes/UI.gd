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
var leader_unit: BaseUnit = null
var group_name: String = "Tribu Shama'Li"
var group_image_path: String = "res://ShamaLi/Assets/Portraits/group.png"

# Portraits et sons par faction
@export var faction_portraits: Dictionary = {
	"Tha'Roon": "res://ThaRoon/Assets/Portraits/tharoon.png"
}
@export var faction_selection_sounds: Dictionary = {
	"Tha'Roon": "res://ThaRoon/Assets/Sounds/tharoon.wav"
}

## Initialise l'interface utilisateur.
func _ready():
	print("Initialisation de l'interface utilisateur.")
	reset_ui()
	emit_signal("ui_ready")

## Réinitialise l'intégralité de l'interface utilisateur.
func reset_ui():
	print("Reset de l'UI.")
	clear_leader_panel()
	clear_unit_panel()
	clear_help_panel()

## Met à jour les informations du leader (nom, santé, ressources).
func update_leader_data(leader: BaseUnit, resource_data: int):
	if leader:
		print("Mise à jour des données du leader : " + leader.stats.unit_name)
		leader_unit = leader
		leader_name = leader.stats.unit_name
		leader_health = leader.stats.health
		leader_health_bar.max_value = leader.stats.health_max
		leader_health_bar.value = leader_health
		leader_name_label.text = leader_name
	else:
		print("Aucun leader défini. Réinitialisation.")
		clear_leader_panel()

	resource_score = resource_data
	resource_score_label.text = str(resource_score)

## Met à jour le panneau d'informations pour une unité sélectionnée.
func update_unit_info(unit: BaseUnit):
	if not unit:
		print("Aucune unité à afficher, réinitialisation du panneau des unités.")
		clear_unit_panel()
		return

	print("Panneau d'information pour l'unité :", unit.stats.unit_name)

	# Nom de l'unité
	unit_name_label.text = unit.stats.unit_name

	# Portrait
	if unit.stats.unit_image:
		unit_image.texture = unit.stats.unit_image
		unit_image.visible = true
	else:
		unit_image.visible = false

	# Barres de vie et mana
	if unit.stats.health_max > 0:
		health_bar.max_value = unit.stats.health_max
		health_bar.value = unit.stats.health
		health_bar.visible = true
	else:
		health_bar.visible = false

	if unit.stats.mana_max > 0:
		mana_bar.max_value = unit.stats.mana_max
		mana_bar.value = unit.stats.mana
		mana_bar.visible = true
	else:
		mana_bar.visible = false

	unit_panel.visible = true

## Met à jour le panneau pour une unité ennemie avec portrait générique et nom de faction.
func update_generic_enemy_info(faction: String, portrait_path: String):
	print("Affichage des informations génériques pour la faction : " + faction)
	unit_name_label.text = faction

	# Portrait
	var texture = ResourceLoader.load(portrait_path)
	if texture and texture is Texture2D:
		unit_image.texture = texture
		unit_image.visible = true
	else:
		unit_image.visible = false

	# Barres de vie et mana (désactivées pour les ennemis)
	health_bar.visible = false
	mana_bar.visible = false

	unit_panel.visible = true

## Met à jour le panneau pour une unité sauvage avec portrait générique.
func update_generic_wild_info(unit: BaseUnit, portrait_path: String = "res://DefaultWildPortrait.png"):
	print("Affichage des informations génériques pour une unité sauvage : " + unit.stats.unit_name)
	unit_name_label.text = unit.stats.unit_name

	# Portrait
	var texture = ResourceLoader.load(portrait_path)
	if texture and texture is Texture2D:
		print("Portrait générique chargé pour une unité sauvage : " + portrait_path)
		unit_image.texture = texture
		unit_image.visible = true
	elif unit.stats.unit_image:  # Si l'unité a une image spécifique
		print("Portrait spécifique chargé pour une unité sauvage.")
		unit_image.texture = unit.stats.unit_image
		unit_image.visible = true
	else:
		print("Aucun portrait disponible pour cette unité sauvage.")
		unit_image.visible = false

	# Barres de vie et mana
	if unit.stats.health_max > 0:
		health_bar.max_value = unit.stats.health_max
		health_bar.value = unit.stats.health
		health_bar.visible = true
	else:
		health_bar.visible = false

	mana_bar.visible = false  # Les unités sauvages n'ont pas de mana

	unit_panel.visible = true

####
## Met à jour le panneau lorsque plusieurs unités sont sélectionnées.
####
func update_multiple_units_info(units: Array):
	if units.is_empty():
		print("Aucune unité multiple sélectionnée, réinitialisation.")
		clear_unit_panel()
		return

	print("Mise à jour pour plusieurs unités. Nombre d'unités : " + str(units.size()))
	unit_name_label.text = group_name
	var group_image = ResourceLoader.load(group_image_path)
	if group_image and group_image is Texture2D:
		print("Image de groupe chargée : " + group_image_path)
		unit_image.texture = group_image
		unit_image.visible = true
	else:
		print("Aucune image de groupe trouvée.")
		unit_image.visible = false

	health_bar.visible = false
	mana_bar.visible = false
	unit_panel.visible = true

####
## Réinitialise les informations du leader.
####
func clear_leader_panel():
	print("Réinitialisation du panneau du leader.")
	leader_name_label.text = "Inconnu"
	leader_health_bar.value = 0
	leader_health_bar.max_value = 100
	resource_score_label.text = "0"

## Réinitialise les informations des unités sélectionnées.
func clear_unit_panel():
	print("Réinitialisation du panneau des unités.")
	unit_panel.visible = false
	unit_name_label.text = ""
	health_bar.visible = false
	mana_bar.visible = false
	unit_image.texture = null
	unit_image.visible = false

## Met à jour la santé d'une unité sélectionnée.
func update_unit_health(unit: BaseUnit, new_health: int):
	if not unit or not unit_panel.visible:
		print("Impossible de mettre à jour la santé, unité ou panneau invisible.")
		return

	if unit.stats and unit.stats.unit_name == unit_name_label.text:
		print("Mise à jour de la santé pour l'unité : " + unit.stats.unit_name)
		health_bar.value = new_health

## Réinitialise le panneau d'aide.
func clear_help_panel():
	print("Réinitialisation du panneau d'aide.")
	help_panel.visible = false
	help_label.text = ""

## Met à jour l'UI en fonction des unités sélectionnées.
## Chaque élément de `selected_units` est un dictionnaire avec :
## - `unit`: Référence à l'unité.
## - `type`: "ally", "enemy", ou "wild".
func update_ui(selected_units: Array):
	print("update_ui appelé. Nombre d'unités sélectionnées : " + str(selected_units.size()))

	if selected_units.is_empty():
		print("Aucune unité sélectionnée. Réinitialisation de l'UI.")
		reset_ui()
	elif selected_units.size() == 1:
		var selection = selected_units[0]
		var unit = selection["unit"]
		var unit_type = selection["type"]

		match unit_type:
			"ally":
				print("Affichage pour une unité alliée : " + unit.stats.unit_name)
				update_unit_info(unit)
			"enemy":
				print("Affichage pour une unité ennemie : " + unit.stats.unit_name)
				if unit.stats:
					var faction = unit.stats.faction if unit.stats else "Unknown"
					var portrait_path = faction_portraits.get(faction, "res://DefaultPortrait.png")
					update_generic_enemy_info(faction, portrait_path)
			"wild":
				print("Affichage pour une unité sauvage : " + unit.stats.unit_name)
				update_unit_info(unit)  # Réutilisation de `update_unit_info` pour l'instant
	else:
		print("Mise à jour de l'UI pour plusieurs unités.")
		var units_array = []
		for item in selected_units:
			units_array.append(item["unit"])
		update_multiple_units_info(units_array)
