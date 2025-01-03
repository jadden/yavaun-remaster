extends BaseUnit

# Position cible pour les déplacements
@export var target_position: Vector2 = Vector2.ZERO

func _ready():
	# Appelle la méthode `_ready()` de la classe parente et ajoute des initialisations spécifiques au Leader
	super._ready()
	print("Leader._ready appelé pour :", name)

func get_unit_menu_data() -> Dictionary:
	# Retourne les données spécifiques au menu du Leader
	print("Leader.get_unit_menu_data() appelé pour :", name)
	return {
		"Move": {},
		"Attack": {},
		"Tournée générale": {},
		"Cancel": {}
	}
