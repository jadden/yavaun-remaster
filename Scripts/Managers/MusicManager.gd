extends Node

var music_streams = {
	"main_menu": preload("res://Assets/Audio/01-Title-Screen.ogg"),
	"race_screen": preload("res://Assets/Audio/02-Race-Screen.ogg"),
	"warrior_of_the_wild": preload("res://Assets/Audio/03-Warrior-of-the-Wild.ogg"),
	"call_to_arms": preload("res://Assets/Audio/04-Call-to-Arms.ogg"),
	"forgotten_forest": preload("res://Assets/Audio/05-Forgotten-Forest.ogg"),
	"hit_the_rocks": preload("res://Assets/Audio/06-Hit-The-Rocks.ogg"),
	"stormfront": preload("res://Assets/Audio/07-Stormfront.ogg"),
	"king_of_the_highlands": preload("res://Assets/Audio/08-King-of-the-Highlands.ogg"),
	"prelude_to_a_war": preload("res://Assets/Audio/09-Prelude-to-a-War.ogg"),
	"shadow_breathers": preload("res://Assets/Audio/10-Shadow-Breathers.ogg"),
	"war_dance": preload("res://Assets/Audio/11-War-Dance.ogg"),
	"where_darkness_lurks": preload("res://Assets/Audio/12-Where-Darkness-Lurks.ogg"),
	"warcry_tharoon": preload("res://Assets/Audio/13-Tha_Roon-Warcry.ogg"),
	"warcry_obblinox": preload("res://Assets/Audio/14-Obblinox-Warcry.ogg"),
	"warcry_eaggra": preload("res://Assets/Audio/15-Eaggra-Warcry.ogg"),
	"warcry_shamali": preload("res://Assets/Audio/16-Shama_Li-Warcry.ogg"),
}

var current_music: String = ""  # Stocke le nom de la musique actuellement jouée

func play_music(music_name: String, loop: bool = true):
	# Vérification initiale
	if not $MusicPlayer:
		print("Erreur : MusicPlayer introuvable dans la scène.")
		return

	# Si la musique demandée est déjà en cours, ne rien faire
	if is_music_playing(music_name):
		print("La musique '", music_name, "' est déjà en lecture.")
		return

	# Vérifie si le nom de musique existe dans le dictionnaire
	if music_name in music_streams:
		var music_stream = music_streams[music_name]
		if not music_stream:
			print("Erreur : La musique '", music_name, "' est introuvable ou mal définie.")
			return

		# Applique le flux de musique
		$MusicPlayer.stream = music_stream
		current_music = music_name
		print("Musique définie : ", music_name)

		# Configure la boucle si applicable
		if $MusicPlayer.stream is AudioStream:
			$MusicPlayer.stream.loop = loop
			print("Paramètre de boucle : ", loop)

		# Lance la lecture
		$MusicPlayer.play()
		print("Lecture de la musique :", music_name)
	else:
		# Gère le cas où le nom n'existe pas
		print("Erreur : La musique '", music_name, "' n'existe pas dans le dictionnaire.")

func stop_music():
	if not $MusicPlayer:
		print("Erreur : MusicPlayer introuvable dans la scène.")
		return
	print("Musique arrêtée.")
	$MusicPlayer.stop()
	current_music = ""  # Réinitialise la musique en cours

func is_music_playing(music_name: String) -> bool:
	# Vérifie si une musique spécifique est actuellement en cours de lecture
	return current_music == music_name and $MusicPlayer.playing

func _on_music_player_finished():
	print("Musique terminée :", current_music)
	current_music = ""  # Réinitialise la musique en cours après la fin
