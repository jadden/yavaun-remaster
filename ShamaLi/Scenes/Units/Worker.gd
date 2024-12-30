extends BaseUnit

func _ready():
	super._ready()  # Appelle la méthode `_ready()` de BaseUnit
	unit_menu_data = {
		"Move": {},
		"Attack": {},
		"Build": {"House": {}, "Inn": {}},
		"Cancel": {}
	}
	print("Worker _ready() appelé.")
