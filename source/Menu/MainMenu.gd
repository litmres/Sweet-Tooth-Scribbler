extends TextureButton

onready var label = get_node("Label")
onready var MenuAnimation = get_parent().get_node("MenuAnimation")

var init_rotation = 0

func _ready():
	init_rotation = rect_rotation


func _process(delta):
	if get_parent().is_game_started:
		label.text = "Main Menu"
	else:
		label.text = "Quit"


func _on_MainMenu_button_down():
	if get_parent().is_game_started:
		rect_rotation = init_rotation
		get_tree().reload_current_scene()
		get_tree().paused = false
	else:
		get_tree().quit()


func _on_MainMenu_mouse_entered():
	modulate = Color(1, 1, 0.7, 1)
	rect_rotation = 0
	get_node("Sfx").play()


func _on_MainMenu_mouse_exited():
	modulate = Color(1, 1, 1, 1)
	rect_rotation = init_rotation


func _on_MainMenu_pressed():
	modulate = Color(0.7, 0.7, 0.7, 1)
