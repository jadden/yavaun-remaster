extends Node

# Variables globales pour la partie en cours
var game_id: String = ""  # UUID de la partie actuelle
var map_name: String = ""  # Nom de la carte en cours
var current_resources: int = 0  # Ressources disponibles sur la carte
var deployed_units: Array = []  # Liste des unités déployées
var scenario_state: Dictionary = {}  # État spécifique du scénario
const SAVE_FILE_PATH: String = "user://game_data.save"

# Suivi des parties terminées (hashé)
var completed_games: Dictionary = {}  # Ex. { "game_uuid": "clan_uuid" }

# Sauvegarder l'état actuel de la partie
func save_game_data():
	if game_id == "":
		game_id = generate_game_id()

	var save_data: Dictionary = {
		"game_id": game_id,
		"map_name": map_name,
		"current_resources": current_resources,
		"deployed_units": deployed_units,
		"scenario_state": scenario_state,
		"completed_games": completed_games
	}

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Partie sauvegardée avec succès :", save_data)
	else:
		print("Erreur : Impossible d'ouvrir le fichier pour sauvegarder.")

# Charger une partie sauvegardée
func load_game_data():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.ModeFlags.READ)
		if file:
			var save_data: Dictionary = file.get_var()
			file.close()

			game_id = save_data.get("game_id", generate_game_id())
			map_name = save_data.get("map_name", "")
			current_resources = save_data.get("current_resources", 0)
			deployed_units = save_data.get("deployed_units", [])
			scenario_state = save_data.get("scenario_state", {})
			completed_games = save_data.get("completed_games", {})
			print("Partie chargée avec succès :", save_data)
		else:
			print("Erreur : Impossible de lire le fichier de sauvegarde.")
	else:
		print("Aucune sauvegarde de partie trouvée.")

# Marquer une partie comme terminée
func mark_game_completed(game_id: String, clan_id: String):
	if game_id != "" and clan_id != "":
		completed_games[game_id] = clan_id
		save_game_data()

# Vérifier si une partie a été terminée par un clan
func is_game_completed_by_clan(game_id: String, clan_id: String) -> bool:
	return completed_games.get(game_id, "") == clan_id

# Générer un ID unique pour la partie
func generate_game_id() -> String:
	var unix_time = str(Time.get_unix_time_from_system())
	var random_part = str(randi())
	return unix_time + "-" + random_part
