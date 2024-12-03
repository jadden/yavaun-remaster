extends Control

# Définition des écrans par race
const CLAN_SCREENS = {
	"Tha'Roon": "res://ThaRoon/Scenes/ClanScreen.tscn",
	"Obblinox": "res://Obblinox/Scenes/ClanScreen.tscn",
	"Eaggra": "res://Eaggra/Scenes/ClanScreen.tscn",
	"Shama'Li": "res://ShamaLi/Scenes/ClanScreen.tscn"
}

@onready var clan_list_container: VBoxContainer = $VBoxContainer/ClanListScroll/VBoxContainer
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var back_button: Button = $VBoxContainer/HBoxContainer/BackButton

func _ready():
	"""
	Initialisation de l'interface.
	"""
	back_button.pressed.connect(_on_BackButton_pressed)

	# Charger les clans via l'Autoload ClanManager
	if ClanManager.clans.is_empty():
		ClanManager.load_clans()

	# Charger et afficher la liste des clans
	load_clan_list()

func load_clan_list():
	"""
	Affiche la liste des clans.
	"""
	# Vider la liste actuelle
	for child in clan_list_container.get_children():
		child.queue_free()

	# Vérifier s'il existe des clans
	if ClanManager.clans.is_empty():
		_display_no_clan_message()
		return

	# Ajouter chaque clan à la liste
	for clan in ClanManager.clans:
		_create_clan_row(clan)

	clan_list_container.queue_sort()
	_reset_scroll()

func _display_no_clan_message():
	"""
	Affiche un message si aucun clan n'existe.
	"""
	var label = Label.new()
	label.text = "Aucun clan existant. Créez-en un nouveau !"
	label.set_size(Vector2(300, 0))  # Limite la largeur du texte
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Étend horizontalement si nécessaire
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Centre verticalement
	clan_list_container.add_child(label)

func _create_clan_row(clan: ClanManager.GameClan):
	"""
	Crée une ligne avec un bouton de sélection et un bouton de suppression.
	"""
	var hbox = HBoxContainer.new()

	# Bouton de sélection du clan
	var clan_button = Button.new()
	clan_button.text = clan.clan_name + " (Leader: " + clan.leader_name + ")"
	clan_button.modulate = clan.get_color()  # Utilisation explicite de la méthode
	clan_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clan_button.pressed.connect(func() -> void:
		_on_ClanButton_pressed(clan)
	)

	# Bouton de suppression
	var delete_button = Button.new()
	delete_button.text = "X"
	delete_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete_button.pressed.connect(func() -> void:
		_on_DeleteButton_pressed(clan.uuid)
	)

	# Ajouter les boutons à la ligne
	hbox.add_child(clan_button)
	hbox.add_child(delete_button)
	clan_list_container.add_child(hbox)

func _reset_scroll():
	"""
	Réinitialise le défilement.
	"""
	if clan_list_container.get_parent() and clan_list_container.get_parent() is ScrollContainer:
		clan_list_container.get_parent().scroll_vertical = 0

func _on_ClanButton_pressed(clan: ClanManager.GameClan):
	"""
	Gère la sélection d'un clan.
	"""
	print("Clan sélectionné :", clan.clan_name, "- UUID:", clan.uuid)
	ClanManager.current_clan_id = clan.uuid  # Stocker l'UUID du clan sélectionné
	ThemeManager.apply_race_theme(clan.race)

	# Charger la scène associée au clan
	var race_screen_path = CLAN_SCREENS.get(clan.race, null)
	if race_screen_path:
		get_tree().change_scene_to_file(race_screen_path)
	else:
		print("Erreur : Impossible de charger l'écran pour la race :", clan.race)

func _on_DeleteButton_pressed(uuid: String):
	"""
	Supprime un clan par UUID.
	"""
	ClanManager.delete_clan_by_uuid(uuid)
	load_clan_list()

func _on_BackButton_pressed():
	"""
	Retour au menu principal.
	"""
	ThemeManager.reset_to_default()
	get_tree().change_scene_to_file("res://Global/Menus/MainMenu.tscn")
