extends BaseUnit

func _ready():
	super._ready()  # Appelle la méthode `_ready()` de BaseUnit
	print("Worker _ready() appelé.")

func get_unit_menu_data() -> Dictionary:
	return {
		"Move": {},
		"Attack": {},
		"Build": {"House": {}, "Inn": {}},
		"Cancel": {}
	}
