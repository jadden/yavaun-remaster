extends CharacterBody2D
class_name BaseUnit

@export var stats: UnitStats
@export var is_selected: bool = false

@onready var visuals: Sprite2D = $Control
@onready var collision_area: Area2D = $CollisionArea2D
@onready var selection_box: Control = $CollisionArea2D/SelectionBox

const CURSOR_FRAMES = [
	"res://Assets/UI/Cursors/select_1.png",
	"res://Assets/UI/Cursors/select_2.png",
	"res://Assets/UI/Cursors/select_3.png",
	"res://Assets/UI/Cursors/select_4.png"
]

var is_hovered: bool = false
var cursor_animation_playing: bool = false

func _ready():
	if selection_box:
		selection_box.visible = false
	else:
		print("Erreur : SelectionBox introuvable pour l'unité ", self.name)

	if collision_area:
		collision_area.mouse_entered.connect(_on_mouse_entered)
		collision_area.mouse_exited.connect(_on_mouse_exited)
	else:
		print("Erreur : CollisionArea2D introuvable pour l'unité ", self.name)

func _on_mouse_entered():
	is_hovered = true
	start_cursor_animation()

func _on_mouse_exited():
	is_hovered = false
	stop_cursor_animation()

func start_cursor_animation():
	if cursor_animation_playing:
		return
	cursor_animation_playing = true
	_animate_cursor()

func stop_cursor_animation():
	cursor_animation_playing = false
	var global_map = get_tree().root.get_node("GlobalMap")
	if global_map:
		global_map.set_default_cursor()

func _animate_cursor():
	var frame_index = 0
	while cursor_animation_playing:
		var cursor_path = CURSOR_FRAMES[frame_index]
		var cursor_texture = load(cursor_path)
		if cursor_texture:
			Input.set_custom_mouse_cursor(cursor_texture)
		frame_index = (frame_index + 1) % CURSOR_FRAMES.size()
		await get_tree().create_timer(0.1).timeout

func set_selected(is_selected: bool):
	self.is_selected = is_selected
	if selection_box:
		selection_box.visible = is_selected
