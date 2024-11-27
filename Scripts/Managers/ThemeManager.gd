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

# Références par défaut
var default_theme: Theme = preload("res://Assets/UI/Theme.tres")
var default_cursor: Texture = preload("res://Assets/UI/Cursors/cursor.png")

# Appliquer le thème par race avec un curseur optionnel
func apply_race_theme(race: String, force_cursor: String = ""):
	var race_data = RACE_THEMES.get(race, null)
	if race_data:
		print("Applying theme for race:", race)

		# Appliquer le thème global
		if race_data.get("theme", null):
			get_tree().root.set_theme(race_data["theme"])
		else:
			print("Aucun thème défini pour la race :", race)

		# Appliquer le curseur (priorité à force_cursor si défini)
		var cursor_path = force_cursor if force_cursor != "" else race_data.get("cursor", null)
		if cursor_path and cursor_path is String:
			var cursor_texture = load(cursor_path)
			if cursor_texture:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				Input.set_custom_mouse_cursor(cursor_texture)
				print("Curseur appliqué :", cursor_path)
			else:
				print("Erreur : Impossible de charger la texture du curseur :", cursor_path)
		else:
			print("Aucun curseur valide défini pour la race :", race)
	else:
		print("Race non trouvée dans RACE_THEMES :", race)

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
	

# Réinitialiser aux valeurs par défaut
func reset_to_default():
	print("Réinitialisation au thème et au curseur par défaut")
	get_tree().root.set_theme(default_theme)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(default_cursor)
