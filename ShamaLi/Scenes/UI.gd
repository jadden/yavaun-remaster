extends Control
class_name ShamaLiUI

#
# ================== SIGNATURE ET PROPRIÉTÉS ==================
#

signal ui_ready

@onready var leader_panel         = $Panel/LeaderPanel
@onready var leader_name_label    = $Panel/LeaderPanel/LeaderName
@onready var leader_health_bar    = $Panel/LeaderPanel/LeaderHealth
@onready var resource_score_label = $Panel/RessourcesScore

@onready var unit_panel           = $Panel/UnitPanel
@onready var unit_name_label      = $Panel/UnitPanel/UnitName
@onready var unit_image           = $Panel/UnitPanel/UnitImage
@onready var health_bar           = $Panel/UnitPanel/HealthBar
@onready var mana_bar             = $Panel/UnitPanel/ManaBar

@onready var help_panel           = $HelpPanel
@onready var help_label           = $HelpPanel/HelpLabel
@onready var minimap              = $Panel/MiniMap

var leader_name: String       = ""
var leader_health: int        = 0
var resource_score: int       = 0
var leader_unit: BaseUnit     = null

var group_name:       String  = "Tribu Shama'Li"
var group_image_path: String  = "res://ShamaLi/Assets/Portraits/group.png"

@export var faction_portraits: Dictionary = {
	"Tha'Roon": "res://ThaRoon/Assets/Portraits/tharoon.png"
}
@export var faction_selection_sounds: Dictionary = {
	"Tha'Roon": "res://ThaRoon/Assets/Sounds/tharoon.wav"
}

#
# ================== INITIALISATION ==================
#

func _ready():
	print("Initialisation de l'interface utilisateur ShamaLiUI.")
	clear_ui()
	emit_signal("ui_ready")

#
# ================== RESET / CLEAR ==================
#

func clear_ui():
	print("Réinitialisation complète de l'UI.")
	clear_leader_panel()
	clear_unit_panel()
	clear_help_panel()

func clear_leader_panel():
	leader_panel.visible = true
	leader_name_label.text = "Inconnu"
	leader_health_bar.value = 0
	leader_health_bar.max_value = 100
	resource_score_label.text = "0"

func clear_unit_panel():
	unit_panel.visible = false
	unit_name_label.text = ""
	unit_image.texture = null
	unit_image.visible = false
	health_bar.visible = false
	mana_bar.visible = false

func clear_help_panel():
	help_panel.visible = false
	help_label.text = ""

#
# ================== MISE À JOUR : LEADER ==================
#

func update_leader_data(leader: BaseUnit, resource_data: int):
	if leader:
		leader_unit = leader
		leader_name = leader.stats.unit_name
		leader_health = leader.stats.health
		leader_name_label.text = leader_name
		leader_health_bar.max_value = leader.stats.health_max
		leader_health_bar.value = leader_health
	else:
		clear_leader_panel()

	resource_score = resource_data
	resource_score_label.text = str(resource_score)

#
# ================== MISE À JOUR : UNITÉS ==================
#

func update_unit_info(unit: BaseUnit):
	if not unit:
		clear_unit_panel()
		return

	unit_panel.visible = true
	unit_name_label.text = unit.stats.unit_name

	# Image de l’unité
	if unit.stats.unit_image:
		unit_image.texture = unit.stats.unit_image
		unit_image.visible = true
	else:
		unit_image.visible = false

	# Barre de vie
	if unit.stats.health_max > 0:
		health_bar.max_value = unit.stats.health_max
		health_bar.value = unit.stats.health
		health_bar.visible = true
	else:
		health_bar.visible = false

	# Barre de mana
	if unit.stats.mana_max > 0:
		mana_bar.max_value = unit.stats.mana_max
		mana_bar.value = unit.stats.mana
		mana_bar.visible = true
	else:
		mana_bar.visible = false

func update_generic_enemy_info(faction: String):
	unit_panel.visible = true
	unit_name_label.text = faction

	var portrait_path = faction_portraits.get(faction, "res://DefaultPortrait.png")
	var texture = load(portrait_path)
	if texture is Texture2D:
		unit_image.texture = texture
		unit_image.visible = true
	else:
		unit_image.visible = false

	health_bar.visible = false
	mana_bar.visible = false

func update_generic_wild_info(unit: BaseUnit, portrait_path: String = "res://DefaultWildPortrait.png"):
	if not unit:
		clear_unit_panel()
		return

	unit_panel.visible = true
	unit_name_label.text = unit.stats.unit_name

	var texture = load(portrait_path)
	if texture is Texture2D:
		unit_image.texture = texture
		unit_image.visible = true
	elif unit.stats.unit_image:
		unit_image.texture = unit.stats.unit_image
		unit_image.visible = true
	else:
		unit_image.visible = false

	if unit.stats.health_max > 0:
		health_bar.max_value = unit.stats.health_max
		health_bar.value = unit.stats.health
		health_bar.visible = true
	else:
		health_bar.visible = false

	mana_bar.visible = false

#
# ================== MISE À JOUR : UNITÉS MULTIPLES ==================
#

func update_multiple_units_info(units: Array):
	if units.is_empty():
		clear_unit_panel()
		return

	unit_panel.visible = true
	unit_name_label.text = group_name

	var group_image_res = load(group_image_path)
	if group_image_res is Texture2D:
		unit_image.texture = group_image_res
		unit_image.visible = true
	else:
		unit_image.visible = false

	health_bar.visible = false
	mana_bar.visible = false

#
# ================== MISC / AUTRES ==================
#

func update_unit_health(unit: BaseUnit, new_health: int):
	if not unit or not unit_panel.visible:
		return

	# Vérifie qu'il s'agit de la même unité actuellement affichée
	if unit.stats.unit_name == unit_name_label.text:
		health_bar.value = new_health

func update_help_panel(info_text: String):
	# Affiche le texte d’aide reçu depuis l’UIManager
	help_panel.visible = true
	help_label.text = info_text

#
# ================== MISE À JOUR CENTRALISÉE (optionnelle) ==================
#

func update_ui(selected_units: Array):
	# Note : Dans ce projet, c'est le UIManager qui décide quoi afficher,
	# mais voici un exemple si on veut tout regrouper ici.
	if selected_units.is_empty():
		clear_ui()
		return

	elif selected_units.size() == 1:
		var data = selected_units[0]
		if not (data.has("unit") and data.has("type")):
			clear_ui()
			return

		var unit = data["unit"]
		var unit_type = data["type"]
		var faction = data.get("faction", "Unknown")

		match unit_type:
			"ally":
				update_unit_info(unit)
			"enemy":
				update_generic_enemy_info(faction)
			"wild":
				update_generic_wild_info(unit)
	else:
		var units_array: Array = []
		for data in selected_units:
			if data.has("unit"):
				units_array.append(data["unit"])

		update_multiple_units_info(units_array)
