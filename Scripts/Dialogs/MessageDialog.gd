extends Popup

@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var close_button: Button = $VBoxContainer/CloseButton

enum MessageType {
	ERROR,
	SUCCESS,
	INFO
}

func _ready():
	close_button.pressed.connect(self.hide)

func set_message(message: String, message_type: int = MessageType.INFO) -> void:
	message_label.text = message
	var font_color: Color = Color.WHITE  # Couleur par défaut

	# Définir la couleur en fonction du type de message
	match message_type:
		MessageType.ERROR:
			font_color = Color.RED
		MessageType.SUCCESS:
			font_color = Color.GREEN
		MessageType.INFO:
			font_color = Color.WHITE
		_:
			font_color = Color.WHITE

	# Appliquer la couleur au Label via un override de thème
	message_label.add_theme_color_override("font_color", font_color)
