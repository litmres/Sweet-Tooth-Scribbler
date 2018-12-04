extends TextureButton

onready var label = get_node("Label")
onready var MenuAnimation = get_parent().get_node("MenuAnimation")

var init_rotation = 0

func _ready():
	init_rotation = rect_rotation


func _on_NewGame_button_down():
	rect_rotation = init_rotation
	if !MenuAnimation.is_playing():
		MenuAnimation.play("To Game")


func _on_NewGame_mouse_entered():
	modulate = Color(1, 1, 0.7, 1)
	rect_rotation = 0
	get_node("Sfx").play()


func _on_NewGame_mouse_exited():
	modulate = Color(1, 1, 1, 1)
	rect_rotation = init_rotation


func _on_NewGame_pressed():
	modulate = Color(0.7, 0.7, 0.7, 1)


func _on_NewGame_visibility_changed():
	modulate = Color(1, 1, 1, 1)
	if !get_parent().is_game_over:
		if get_parent().is_game_started:
			label.text = "Continue"
		if !get_parent().is_game_started:
			label.text = "New Game"
	else:
		label.text = "View Body"
