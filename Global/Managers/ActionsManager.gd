extends Node

# Liste des actions en cours
var actions: Array = []

# Fonction appelée pour ajouter une action
func add_action(unit: Node, action_type: String, data: Dictionary) -> void:
	# Ajoute une nouvelle action à la liste des actions en cours.
	if not unit:
		print("Erreur : L'unité est invalide.")
		return
	actions.append({
		"unit": unit,
		"type": action_type,
		"data": data,
		"completed": false
	})
	print("Action ajoutée :", action_type, "pour l'unité :", unit.name)

# Fonction principale pour traiter les actions
func process_actions(delta: float) -> void:
	# Parcourt toutes les actions en cours et traite celles qui ne sont pas encore terminées.
	for action in actions:
		if action["completed"]:
			continue

		match action["type"]:
			"move":
				_process_move_action(action, delta)
			_:
				print("Type d'action non pris en charge :", action["type"])

	# Nettoyage des actions terminées
	_clean_up_completed_actions()

# Nettoyage des actions terminées
func _clean_up_completed_actions() -> void:
	# Supprime les actions terminées de la liste.
	var remaining_actions = []
	for action in actions:
		if not action["completed"]:
			remaining_actions.append(action)
	actions = remaining_actions


## Gestion du déplacement
## Traite une action de type "move" pour déplacer une unité vers une position cible.
func _process_move_action(action: Dictionary, delta: float) -> void:
	var unit = action["unit"]
	var target_position = action["data"].get("target_position")
	var speed = action["data"].get("speed", 200)

	# Vérifier que l'unité est valide
	if not unit or not unit.has_method("set_position"):
		print("Erreur : L'unité est invalide ou ne peut pas être déplacée.")
		action["completed"] = true
		return

	# Vérifier que la position cible est valide
	if not target_position:
		print("Erreur : Position cible manquante pour l'unité :", unit.name)
		action["completed"] = true
		return

	# Calculer la direction et déplacer l'unité
	var current_position = unit.get_position()
	var direction = (target_position - current_position).normalized()
	var distance = speed * delta

	# Vérifier si la destination est atteinte
	if current_position.distance_to(target_position) <= distance:
		unit.set_position(target_position)
		action["completed"] = true
		print("L'unité :", unit.name, "a atteint sa destination :", target_position)
	else:
		unit.set_position(current_position + direction * distance)
		print("L'unité :", unit.name, "se déplace vers :", target_position)
