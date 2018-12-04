extends "res://DraggableTextureButton.gd"

export var is_healthy = false
export var food_points = 5.0

export(String, "Donut", "Broccoli") var food_name
export var food_cost = 5.0

onready var EatenAnimPlayer = get_node("EatenAnimPlayer")

#onready var Stars = [get_node("Star1"), get_node("Star2"), get_node("Star3")]

const GRADE = [1, 2, 3]

var food_grade = GRADE[0]
var move_speed = 5


func _ready():
	offset = Vector2(30, 30)
	connect_picked_up_signal(get_tree().root.get_node("Game"))
	randomize()
	food_cost = ceil(rand_range(2.0, 10.0))
	food_grade = GRADE[randi() % GRADE.size()]
	move_speed = ceil(rand_range(5, 100))
	rect_rotation = rand_range(0, 360)
	rect_scale *= food_grade
	rect_scale *= 0.5

#	for i in range(Stars.size()):
#		Stars[i].hide()
#	for i in range(food_grade):
#		Stars[i].show()


func _process(delta):
	rect_position.y -= move_speed * delta


func get_eaten():
	move_speed = 0
	EatenAnimPlayer.play("Eaten")
	disconnect_picked_up_signal(get_parent())


func _on_mouse_entered():
	if get_parent().current_funds >= food_cost:
		is_mouse_over = true
	else:
		var FundsAnimation = get_parent().get_node("FundsAnimation")
		if !FundsAnimation.is_playing():
			FundsAnimation.play("Out of Funds")
	modulate = Color(0.8, 0.8, 0.5, 1)


func _on_mouse_exited():
	is_mouse_over = false
	modulate = Color(1, 1, 1, 1)

func ate():
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
