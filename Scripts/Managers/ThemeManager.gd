extends Node

# Dictionnaire des thèmes et curseurs par race
const RACE_THEMES = {
	"Tha'Roon": {
		"theme": preload("res://ThaRoon/Assets/UI/Theme.tres"),
		"cursor": preload("res://ThaRoon/Assets/UI/cursor.png"),
		"ui": "res://ThaRoon/Scenes/UI.tscn"
	},
	"Obblinox": {
		"theme": preload("res://Obblinox/Assets/UI/Theme.tres"),
		"cursor": preload("res://Obblinox/Assets/UI/cursor.png"),
		"ui": "res://Obblinox/Scenes/UI.tscn"
	},
	"Eaggra": {
		"theme": preload("res://Eaggra/Assets/UI/Theme.tres"),
		"cursor": preload("res://Eaggra/Assets/UI/cursor.png"),
		"ui": "res://Eaggra/Scenes/UI.tscn"
	},
	"Shama'Li": {
		"theme": preload("res://ShamaLi/Assets/UI/Theme.tres"),
		"cursor": preload("res://ShamaLi/Assets/UI/cursor.png"),
		"ui": "res://ShamaLi/Scenes/UI.tscn"
	}
}

# Couleurs globales pour les barres
const COLOR_HEALTH = Color("#bec641")  # Jaune
const COLOR_MANA = Color("#316fc7")  # Bleu

# Références par défaut
var default_theme: Theme = preload("res://Assets/UI/Theme.tres")
var default_cursor: Texture = preload("res://Assets/UI/Cursors/cursor.png")

# Appliquer le thème par race
func apply_race_theme(race: String):
	var race_data = RACE_THEMES.get(race, null)
	if race_data:
		print("Applying theme for race:", race)

		# Appliquer le thème global
		if race_data.get("theme", null):
			get_tree().root.set_theme(race_data["theme"])
		else:
			print("Aucun thème défini pour la race:", race)

		# Appliquer le curseur
		if race_data.get("cursor", null):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.set_custom_mouse_cursor(race_data["cursor"])
		else:
			print("Aucun curseur défini pour la race:", race)
	else:
		print("Race non trouvée dans RACE_THEMES:", race)

# Charger l'interface utilisateur spécifique par race
func apply_race_ui(race: String, container: Node) -> Node:
	var race_data = RACE_THEMES.get(race, null)
	if race_data:
		var ui_scene_path = race_data.get("ui", null)
		if ui_scene_path:
			var ui_scene = load(ui_scene_path)
			if ui_scene:
				var ui_instance = ui_scene.instantiate()
				container.add_child(ui_instance)
				print("UI spécifique chargée pour la race:", race)
				return ui_instance  # Retourne l'instance de l'UI
			else:
				print("Impossible de charger la scène UI pour la race:", race)
		else:
			print("Pas d'UI définie pour la race:", race)
	else:
		print("Race non définie dans RACE_THEMES:", race)
	return null

# Appliquer une couleur à une ProgressBar
static func apply_bar_color(progress_bar: ProgressBar, color: Color):
	if not progress_bar or not progress_bar.is_class("ProgressBar"):
		print("Erreur : ProgressBar non valide")
		return

	var style = progress_bar.get_theme_stylebox("fg", "ProgressBar")
	if not style:  # Si aucun style existant, créer un nouveau StyleBoxFlat
		style = StyleBoxFlat.new()

	# Appliquer la couleur
	if style is StyleBoxFlat:
		style.bg_color = color
		progress_bar.add_theme_stylebox_override("fg", style)
	else:
		print("Erreur : Style non compatible pour la ProgressBar")


# Réinitialiser aux valeurs par défaut
func reset_to_default():
	print("Réinitialisation au thème et au curseur par défaut")
	get_tree().root.set_theme(default_theme)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(default_cursor)
