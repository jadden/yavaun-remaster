extends BaseUnit

@export var target_position: Vector2 = Vector2.ZERO

func _ready():
	super._ready()  # Appelle la méthode `_ready()` de BaseUnit
	print("Leader _ready() appelé.")
