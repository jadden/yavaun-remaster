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

func print_debug(message: String, category: String = "UI"):
	"""
	Utilitaire pour afficher les logs avec une catégorie.
	"""
	print("[" + category + "] " + message)

func _ready():
	"""
	Initialise l'interface utilisateur.
	"""
	reset_ui()  # Réinitialise l'interface complète
	print_debug("Interface Raciale ShamaLiUI initialisée.")
	emit_signal("ui_ready")

func reset_ui():
	"""
	Remet à zéro l'intégralité de l'interface utilisateur (leader + unités).
	"""
	clear_ui()
	clear_unit_panel()
	clear_help_panel()
	print_debug("UI entièrement réinitialisée.")

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
		_play_selection_sound(leader)
	else:
		clear_ui()  # Efface les données si aucun leader

	resource_score = resource_data
	resource_score_label.text = str(resource_score)

	print_debug("Mise à jour des données du leader :")
	print_debug(" - Nom : " + leader_name)
	print_debug(" - Santé : " + str(leader_health))
	print_debug(" - Ressources : " + str(resource_score))

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
	_play_selection_sound(unit)
	print_debug("Panneau mis à jour pour l'unité sélectionnée : " + unit.stats.unit_name)

func update_unit_portrait(portrait_path: String):
	"""
	Met à jour le portrait de l'unité affichée.
	"""
	if typeof(portrait_path) == TYPE_STRING and portrait_path != "":
		var texture = ResourceLoader.load(portrait_path)
		if texture and texture is Texture2D:
			unit_image.texture = texture
			unit_image.visible = true
			print_debug("Portrait mis à jour depuis :", portrait_path)
		else:
			print_debug("Erreur : Impossible de charger le portrait depuis :", portrait_path)
	else:
		unit_image.visible = false
		print_debug("Aucun portrait disponible pour mise à jour.")


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

	# Joue le son de la première unité dans le groupe
	if units.size() > 0:
		_play_selection_sound(units[0])

	print_debug("Panneau mis à jour pour plusieurs unités : " + str(units.size()))

func _play_selection_sound(unit: BaseUnit):
	"""
	Joue le son de sélection d'une unité si disponible.
	"""
	if not unit or not unit.stats:
		return

	# Vérifie dynamiquement si la propriété existe
	if unit.stats.has_property("unit_sound_selection_path"):
		var sound_path = unit.stats.unit_sound_selection_path
		if sound_path and sound_path.strip_edges() != "":
			SoundManager.play_sound_from_path(sound_path)  # Utilise le SoundManager autoload
			print_debug("Son de sélection joué pour :", unit.stats.unit_name)
		else:
			print_debug("Aucun chemin valide pour le son :", unit.stats.unit_name)
	else:
		print_debug("Aucun son de sélection défini pour l'unité :", unit.stats.unit_name)

func clear_ui():
	"""
	Réinitialise les informations du leader.
	"""
	leader_name_label.text = "Inconnu"
	leader_health_bar.value = 0
	leader_health_bar.max_value = 100
	resource_score_label.text = "0"
	print_debug("Données du leader réinitialisées.")

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
	print_debug("Panneau d'unité réinitialisé.")

func update_leader_health(new_health: int):
	"""
	Met à jour la santé du leader dynamiquement.
	"""
	if leader_unit:
		leader_health = new_health
		leader_health_bar.value = leader_health
		print_debug("Santé du leader mise à jour : " + str(leader_health))

func update_resource_score(new_score: int):
	"""
	Met à jour les ressources dynamiquement.
	"""
	resource_score = new_score
	resource_score_label.text = str(new_score)
	print_debug("Score de ressources mis à jour : " + str(resource_score))

func update_help_panel(entity_name: String):
	"""
	Affiche des informations contextuelles sur une entité.
	"""
	if not entity_name:
		clear_help_panel()
		return

	help_label.text = "Type: " + entity_name
	help_panel.visible = true
	print_debug("Panneau d'aide mis à jour pour l'entité : " + entity_name)

func clear_help_panel():
	"""
	Réinitialise le panneau d'aide.
	"""
	help_panel.visible = false
	help_label.text = ""
	print_debug("Panneau d'aide réinitialisé.")

func update_minimap(data):
	"""
	Placeholder pour la gestion de la minimap.
	"""
	print_debug("Mise à jour de la minimap avec les données : " + str(data))

func update_unit_health(unit: BaseUnit, new_health: int):
	"""
	Met à jour la santé d'une unité sélectionnée.
	"""
	if not unit or not unit_panel.visible:
		print_debug("Aucune unité sélectionnée ou panneau non visible.", "Erreur")
		return

	if unit.stats and unit.stats.unit_name == unit_name_label.text:
		health_bar.value = new_health
		print_debug("Santé mise à jour pour l'unité : " + unit.stats.unit_name + " -> " + str(new_health))
	else:
		print_debug("Unité non correspondante pour la mise à jour de la santé.", "Erreur")
