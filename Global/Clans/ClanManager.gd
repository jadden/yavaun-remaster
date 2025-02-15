extends Node

# Liste des clans
var clans: Array = []
var current_race: String = ""
var current_clan_id: String = ""  # UUID du clan actuellement sélectionné

# Fichier de sauvegarde
const SAVE_FILE_PATH: String = "user://clans.json"

# Classe interne GameClan
class GameClan:
	var uuid: String
	var clan_name: String
	var leader_name: String
	var race: String
	var clan_color: Color

	func _init(clan_name: String, leader_name: String, race: String, clan_color: Color, uuid: String = ""):
		self.clan_name = clan_name
		self.leader_name = leader_name
		self.race = race
		self.clan_color = clan_color
		self.uuid = uuid if uuid != "" else ClanManager.generate_uuid()

	func get_color() -> Color:
		return clan_color

	func to_dict() -> Dictionary:
		return {
			"uuid": uuid,
			"clan_name": clan_name,
			"leader_name": leader_name,
			"race": race,
			"clan_color": clan_color.to_html()
		}

	static func from_dict(data: Dictionary) -> GameClan:
		return GameClan.new(
			data.get("clan_name", "Default Clan"),
			data.get("leader_name", "Default Leader"),
			data.get("race", ""),
			Color(data.get("clan_color", "#FFFFFF")),
			data.get("uuid", "")
		)

# Ajouter un clan
func add_clan(clan: GameClan):
	clans.append(clan)
	save_clans()

# Charger les clans depuis le fichier JSON
func load_clans():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.ModeFlags.READ)
		var json_data = file.get_as_text()
		file.close()

		var parsed_data = JSON.parse_string(json_data)
		if typeof(parsed_data) == TYPE_ARRAY:
			clans.clear()
			for clan_dict in parsed_data:
				var clan = GameClan.from_dict(clan_dict)
				clans.append(clan)
			print("Clans chargés :", clans)
		else:
			print("Erreur : Les données JSON ne sont pas au format attendu.")
	else:
		print("Aucun fichier de sauvegarde trouvé.")

# Sauvegarder les clans dans un fichier JSON
func save_clans():
	var save_data: Array = []
	for clan in clans:
		save_data.append(clan.to_dict())

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.ModeFlags.WRITE)
	var json_data = JSON.stringify(save_data)
	file.store_string(json_data)
	file.close()
	print("Clans sauvegardés :", save_data)

# Générer un UUID unique
static func generate_uuid() -> String:
	var unix_time = str(Time.get_unix_time_from_system())
	var random_part = str(randi())
	return unix_time + "-" + random_part

# Supprimer un clan par UUID
func delete_clan_by_uuid(uuid: String):
	for i in range(clans.size()):
		if clans[i].uuid == uuid:
			clans.remove_at(i)
			save_clans()
			print("Clan supprimé :", uuid)
			return
	print("Erreur : Clan non trouvé pour UUID :", uuid)

# Afficher les UUID des clans pour débogage
func print_clan_uuids():
	for clan in clans:
		print("Clan:", clan.clan_name, "- UUID:", clan.uuid)
