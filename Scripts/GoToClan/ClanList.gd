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
	# Connecter le bouton de retour
	back_button.pressed.connect(_on_BackButton_pressed)

	# Charger les clans si nécessaire
	if GameData.clans.is_empty():
		GameData.load_clans()

	# Charger et afficher la liste des clans
	load_clan_list()

func load_clan_list():
	# Vider la liste actuelle
	for child in clan_list_container.get_children():
		child.queue_free()

	# Vérifier s'il existe des clans
	if GameData.clans.size() == 0:
		_display_no_clan_message()
		return

	# Ajouter chaque clan à la liste
	for clan in GameData.clans:
		_create_clan_button(clan)

	# Forcer la mise à jour du conteneur
	clan_list_container.queue_sort()

	# Réinitialiser le défilement si dans un ScrollContainer
	_reset_scroll()

func _display_no_clan_message():
	# Crée un conteneur centré
	var center_container = CenterContainer.new()
	center_container.name = "NoClanCenterContainer"

	# Crée le label
	var no_clan_label = Label.new()
	no_clan_label.text = "Aucun clan existant. Créez-en un nouveau !"
	no_clan_label.autowrap = true  # Permet au texte de s'adapter à la largeur
	no_clan_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Exemple : texte rouge (optionnel)

	# Ajouter le label au conteneur centré
	center_container.add_child(no_clan_label)

	# Ajouter le conteneur centré à la liste
	clan_list_container.add_child(center_container)


func _create_clan_button(clan):
	print("Ajout du clan : ", clan.clan_name)
	var clan_button = Button.new()
	clan_button.text = clan.clan_name + " (Leader: " + clan.leader_name + ")"
	clan_button.modulate = clan.profile.clan_color

	# Connecter le bouton au gestionnaire de sélection
	clan_button.pressed.connect(func() -> void:
		_on_ClanButton_pressed(clan)
	)

	clan_list_container.add_child(clan_button)

func _reset_scroll():
	if clan_list_container.get_parent() and clan_list_container.get_parent() is ScrollContainer:
		clan_list_container.get_parent().scroll_vertical = 0

func _on_ClanButton_pressed(clan):
	# Appliquer le thème de la race via le ThemeManager
	ThemeManager.apply_race_theme(clan.race)

	# Charger la scène associée au clan
	var race_screen_path = CLAN_SCREENS.get(clan.race, null)
	if race_screen_path:
		get_tree().change_scene_to_file(race_screen_path)
	else:
		GameData.show_message_dialog(
			"Impossible de charger l'écran pour la race : " + clan.race,
			GameData.MessageType.ERROR
		)

func _on_BackButton_pressed():
	# Réinitialiser le thème et le curseur par défaut
	ThemeManager.reset_to_default()

	# Retourner au menu principal
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
