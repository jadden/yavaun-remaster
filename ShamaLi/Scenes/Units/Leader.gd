extends BaseUnit


@export var target_position: Vector2 = Vector2.ZERO

func _ready():
	super._ready()  # Appelle la méthode `_ready()` de BaseUnit
	unit_menu_data = {
		"Move": {},
		"Attack": {},
		"Tournée générale": {},
		"Cancel": {}
	}
	print("Leader _ready() appelé.")
