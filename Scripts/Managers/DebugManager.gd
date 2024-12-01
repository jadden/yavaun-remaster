extends Node

# Liste des catégories de logs activées
var active_categories: Dictionary = {
	"general": true,
	"selection": true,
	"ui": true,
	"entities": true,
	"errors": true
}

func _ready():
	print("[DebugManager] Initialisé et prêt.")

func debug_log(message: String, category: String = "general"):
	if active_categories.get(category, false):
		print("[", category.to_upper(), "]", message)
	else:
		print("[DEBUG][DISABLED CATEGORY]:", category, "-", message)

# Assurez-vous qu'il n'est pas libéré
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("[ERROR][DebugManager] Tentative de libération détectée.")
