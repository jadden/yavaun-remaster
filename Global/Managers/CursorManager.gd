extends Node
class_name CursorManager

@export var cursor_images: Array
var cursor_animation_index: int = 0
var cursor_animation_timer: Timer = null

func _ready():
	cursor_animation_timer = Timer.new()
	cursor_animation_timer.one_shot = false
	cursor_animation_timer.wait_time = 0.1
	cursor_animation_timer.connect("timeout", Callable(self, "_animate_cursor"))
	add_child(cursor_animation_timer)

func start_cursor_animation():
	cursor_animation_index = 0
	cursor_animation_timer.start()

func stop_cursor_animation():
	cursor_animation_timer.stop()
	Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[0]))

func _animate_cursor():
	Input.set_custom_mouse_cursor(ResourceLoader.load(cursor_images[cursor_animation_index]))
	cursor_animation_index = (cursor_animation_index + 1) % cursor_images.size()
