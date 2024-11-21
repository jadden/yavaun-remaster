extends Node

# Variables globales
var clans: Array = []  # Liste des clans existants
var current_clan: Clan = null  # Clan actuellement sélectionné
var race: String = ""  # Race sélectionnée
const SAVE_FILE_PATH: String = "user://clans.save"

# Enum pour les types de messages (utile si vous centralisez les dialogues)
enum MessageType {
	ERROR,
	SUCCESS,
	INFO
}

# Classe pour représenter un Clan
class Clan:
	var clan_name: String
	var leader_name: String
	var race: String
	var profile: ClanProfile

	func _init(name: String, leader: String, race: String, profile: ClanProfile):
		clan_name = name
		leader_name = leader
		self.race = race
		self.profile = profile

# Classe pour représenter un Profil de Clan
class ClanProfile:
	var clan_color: Color
	var clan_icon: Texture

	func _init(color: Color, icon: Texture):
		self.clan_color = color
		self.clan_icon = icon

# Fonction pour ajouter un nouveau clan
func add_clan(clan_name: String, leader_name: String, race: String, profile: ClanProfile) -> void:
	var new_clan: Clan = Clan.new(clan_name, leader_name, race, profile)
	clans.append(new_clan)

# Fonction pour charger les clans depuis un fichier
func load_clans() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.ModeFlags.READ)
		if file:
			var save_data: Array = file.get_var()
			print("Données chargées : ", save_data)  # Debugging
			for clan_dict in save_data:
				# Vérifiez que les clés existent dans le dictionnaire
				if "clan_color" in clan_dict and "clan_icon_path" in clan_dict and "clan_name" in clan_dict and "leader_name" in clan_dict and "race" in clan_dict:
					var clan_color: Color = Color(clan_dict["clan_color"])
					var clan_icon: Texture = load(clan_dict["clan_icon_path"])
					var profile: ClanProfile = ClanProfile.new(clan_color, clan_icon)
					add_clan(clan_dict["clan_name"], clan_dict["leader_name"], clan_dict["race"], profile)
				else:
					print("Données de clan incomplètes : ", clan_dict)
			file.close()
			print("Clans chargés avec succès.")
		else:
			print("Erreur lors du chargement des clans.")
	else:
		print("Aucun fichier de sauvegarde trouvé.")

# Fonction pour sauvegarder les clans dans un fichier
func save_clans() -> void:
	var save_data: Array = []
	for clan in clans:
		var clan_dict: Dictionary = {
			"clan_name": clan.clan_name,
			"leader_name": clan.leader_name,
			"race": clan.race,
			"clan_color": clan.profile.clan_color.to_html(),
			"clan_icon_path": clan.profile.clan_icon.resource_path  # Assurez-vous que les icônes sont correctement référencées
		}
		save_data.append(clan_dict)
	
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Clans sauvegardés avec succès : ", save_data)  # Debugging
	else:
		print("Erreur lors de la sauvegarde des clans.")

# Fonction centralisée pour afficher les messages de dialogue
func show_message_dialog(message: String, message_type: int = MessageType.INFO) -> void:
	var dialog_scene: PackedScene = preload("res://Scenes/Dialogs/MessageDialog.tscn")
	var dialog_instance: Popup = dialog_scene.instantiate()
	get_tree().current_scene.add_child(dialog_instance)  # Ajoutez le Popup à la scène courante
	if dialog_instance.has_method("set_message"):
		dialog_instance.set_message(message, message_type)
		dialog_instance.popup_centered()
	else:
		print("Erreur : La scène de dialogue ne possède pas la méthode 'set_message'.")

# Fonction pour charger le profil de clan basé sur la race
func load_clan_profile() -> ClanProfile:
	match race:
		"Tha'Roon":
			return ClanProfile.new(Color("#FF0000"), load("res://UI/Icons/ThaRoonIcon.png"))
		"Obblinox":
			return ClanProfile.new(Color("#00FF00"), load("res://UI/Icons/ObblinoxIcon.png"))
		"Eaggra":
			return ClanProfile.new(Color("#0000FF"), load("res://UI/Icons/EaggraIcon.png"))
		"Shama'Li":
			return ClanProfile.new(Color("#FFFF00"), load("res://UI/Icons/ShamaLiIcon.png"))
		_:
			return ClanProfile.new(Color("#FFFFFF"), load("res://UI/Icons/DefaultClanIcon.png"))
