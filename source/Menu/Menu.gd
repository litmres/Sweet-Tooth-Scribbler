extends Button

onready var MenuAnimation = get_parent().get_node("MenuAnimation")


func _process(delta):
	if get_parent().is_gameplay_started:
		show()
	else:
		hide()


func _on_Menu_pressed():
	MenuAnimation.play("To Menu")
