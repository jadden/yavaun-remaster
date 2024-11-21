extends Node2D

func _ready():
	# Récupère la taille de la fenêtre
	var window_size = get_viewport_rect().size

	# Centre le logo
	var logo_sprite = $LogoSprite
	logo_sprite.position = window_size / 2

	# Attendre 0,5 seconde
	await get_tree().create_timer(0.5).timeout

	# Faire tourner le logo une fois sur lui-même
	await rotate_logo_once(1.0)  # Durée de rotation : 1 seconde (ajustez si nécessaire)

	# Attendre 0,5 seconde
	await get_tree().create_timer(0.5).timeout

	# Changer de scène
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func rotate_logo_once(duration):
	var tween = create_tween()
	tween.tween_property($LogoSprite, "rotation_degrees", $LogoSprite.rotation_degrees + 360, duration)
	await tween.finished
