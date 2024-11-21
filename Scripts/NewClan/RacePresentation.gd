# res://Scripts/RacePresentation.gd
extends Popup

@onready var race_name_label = $PanelContainer/VBoxContainer/RaceNameLabel
@onready var race_icon = $PanelContainer/VBoxContainer/RaceIcon
@onready var race_description = $PanelContainer/VBoxContainer/RaceDescription
@onready var close_button = $PanelContainer/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(self.hide)

func set_race(race_name: String):
	race_name_label.text = race_name
	match race_name:
		"Tha'Roon":
			race_icon.texture = preload("res://ThaRoon/Assets/Portraits/tharoon.png")
			race_description.text = "Les Tha'Roon sont une race redoutable, connue pour..."
		"Obblinox":
			race_icon.texture = preload("res://Obblinox/Assets/Portraits/obblinox.png")
			race_description.text = "Les Obblinox sont réputés pour..."
		"Eaggra":
			race_icon.texture = preload("res://Eaggra/Assets/Portraits/eaggra.png")
			race_description.text = "Les Eaggra excellent dans..."
		"Shama'Li":
			race_icon.texture = preload("res://ShamaLi/Assets/Portraits/shamali.png")
			race_description.text = "Les Shama'Li possèdent des capacités uniques..."
		_:
			race_icon.texture = null
			race_description.text = "Race inconnue."

func _on_CloseButton_pressed():
	hide()
