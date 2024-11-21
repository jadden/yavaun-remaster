extends Control

@onready var unit_name_label = $Panel/UnitName
@onready var health_bar = $Panel/HealthBar
@onready var mana_bar = $Panel/ManaBar

# Met à jour l'interface avec les données de l'unité sélectionnée
func update_ui(unit: BaseUnit):
	unit_name_label.text = unit.unit_name
	health_bar.value = unit.health
	health_bar.max_value = unit.health_max
	mana_bar.value = unit.mana
	mana_bar.max_value = unit.mana_max

# Réinitialise l'interface (aucune unité sélectionnée)
func clear_ui():
	unit_name_label.text = "Aucune unité sélectionnée"
	health_bar.value = 0
	mana_bar.value = 0
