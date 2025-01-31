extends Panel

@onready var screenSize = DisplayServer.window_get_size()

var fullscreen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$image/TextureRect/points/ScrollContainer/GridContainer/CheckButton.button_pressed = true
	
	$image/TextureRect/points/ScrollContainer/GridContainer/resolution.set_item_text(0, str(screenSize.x , "×" ,screenSize.y))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fullscreen:
		$image/TextureRect/points/ScrollContainer/GridContainer/resolution.disabled = true
		var FullscreenSize = DisplayServer.window_get_size()
		$image/TextureRect/points/ScrollContainer/GridContainer/resolution.select(0)
		$image/TextureRect/points/ScrollContainer/GridContainer/resolution.set_item_text(0, str(FullscreenSize.x , "×" ,FullscreenSize.y))
	else:
		$image/TextureRect/points/ScrollContainer/GridContainer/resolution.disabled = false
		$image/TextureRect/points/ScrollContainer/GridContainer/resolution.set_item_text(0, str(screenSize.x , "×" ,screenSize.y))


func _on_resolution_item_selected(index: int) -> void:
	if !fullscreen:
		match index:
			0:
				DisplayServer.window_set_size(screenSize)
			1:
				DisplayServer.window_set_size(Vector2i(1366, 768))
			2:
				DisplayServer.window_set_size(Vector2i(1920, 1080))
			3:
				DisplayServer.window_set_size(Vector2i(2560, 1440))


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)  # Включает полный экран
		fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)  # Возвращает в оконный режим
		fullscreen = false


func _on_close_pressed() -> void:
	visible = false
