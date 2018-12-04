extends "res://DraggableTextureButton.gd"

signal displayed_poem(poem, is_displaying)

onready var ScoreDisplay = get_node("ScoreDisplay")
#onready var DestroyTimer = get_node("DestroyTimer")

onready var HoverSfx = get_node("HoverSfx")

onready var Lines = [get_node("Sprite"),
					 get_node("Sprite2"),
					 get_node("Sprite3"),
					 get_node("Sprite4"),
					 get_node("Sprite5"),
					 get_node("Sprite6")]

var poem = []
var score = 0

var paper_cost = 2

var target_pos = Vector2(700, 330)
var lerp_speed = 5
var ready_to_be_compiled = false

var current_color = Color(1, 1, 1, 1)

func _ready():
	offset = Vector2(48, 50)
	connect_picked_up_signal(get_parent())
	connect("displayed_poem", get_parent(), "_on_Paper_displayed_poem")
	set_process(false)
	modulate_according_to_score()


func modulate_according_to_score():
	if score < 0:
		modulate = Color(0.93, 0.76, 0.76, 1)
		current_color = modulate
	if score >= 0:
		modulate = Color(0.7, 1, 0.7, 1)
		current_color = modulate


func show_written_lines(lines):
	for i in range(lines):
		Lines[i].show()
	modulate_according_to_score()


func _process(delta):
	rect_position = rect_position.linear_interpolate(target_pos, lerp_speed * delta)
	modulate_according_to_score()


func _on_mouse_entered():
	ScoreDisplay.text = String(score)
	ScoreDisplay.visible = true
	modulate = Color(1, 1, 0.7, 1)
	is_mouse_over = true
	emit_signal("displayed_poem", poem, true)
	HoverSfx.play()


func _on_mouse_exited():
	ScoreDisplay.visible = false
	modulate = current_color
	is_mouse_over = false
	emit_signal("displayed_poem", poem, false)


func _on_paper_compiled():
	if ready_to_be_compiled:
		randomize()
		lerp_speed = rand_range(1, 5)
		target_pos = Vector2(rand_range(600, 800), -200)


func _on_Timer_timeout():
	set_process(true)
	disconnect_picked_up_signal(get_parent())
#	DestroyTimer.start()
	raise()
	get_parent().last_poem = poem
	get_parent().paper_scores.append(score)
	ready_to_be_compiled = true


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if !get_tree().paused:
		queue_free()

