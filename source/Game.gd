extends Node2D

signal something_held(thing)

onready var MinPosPaper = get_node("MinPosPaper")
onready var MaxPosPaper = get_node("MaxPosPaper")

onready var HealthBar = get_node("HealthBar")
onready var StomachBar = get_node("StomachBar")
onready var MoodBar = get_node("MoodBar")

onready var Poem = get_node("Poem")

onready var Scribbler = get_node("Scribbler")
onready var FoodSpawner = get_node("FoodSpawner")

onready var FundsLabel = get_node("FundsLabel")
onready var DeadlineLabel = get_node("DeadlineLabel")
onready var ReputationLabel = get_node("ReputationLabel")

onready var DeadlineTimer = get_node("DeadlineTimer")

onready var IntroAnimation = get_node("IntroAnimation")
onready var IntroMonologue = get_node("IntroMonologue")
onready var IntroTimer = get_node("IntroTimer")
onready var IntroSkip = get_node("IntroSkip")
onready var IntroNameLabel = get_node("IntroNameLabel")

onready var MenuAnimation = get_node("MenuAnimation")

onready var GameOverPoem = get_node("GameOverPoem")
onready var TitleSprite = get_node("TitleSprite")

onready var MusicList = [get_node("MusicMenu"), get_node("MusicIntro"), get_node("MusicPlay"), get_node("MusicGameOver")]

var current_music

var hovered_object
var hovered_object_offset = Vector2()

var is_picking = false

var displayed_text_array = []

var paper_compiled = []
var last_poem = []

var current_funds = 10000.00
var salary = 100.0

var days_to_deadline = 5
var prev_days_to_deadline = 5

const REPUTATION_NICKNAMES = ["Excellent", "Very good", "Good", "Normal", "Bad", "Very bad", "Terrible"]
var reputation = 0
var reputation_nickname = "Normal"

var is_game_started = false
var is_intro = true

var is_gameplay_started = false
var is_game_over = false


func _ready():
	HealthBar.value = Scribbler.health
	StomachBar.value = Scribbler.stomach
	MoodBar.value = Scribbler.mood

	FundsLabel.text = "FUNDS: $" + String(current_funds)
	reputation_nickname = reputation_nickname.to_upper()
	ReputationLabel.text = "YOUR REPUTATION: " + String(reputation) + " (" + reputation_nickname + ")"

	if !is_connected("something_held", get_node("Scribbler"), "_on_something_held"):
		connect("something_held", get_node("Scribbler"), "_on_something_held")

	play_music(0)
#	new_game()
	OS.window_maximized = true


func _process(delta):
	if hovered_object != null && is_picking:
		hovered_object.rect_position = get_global_mouse_position() - hovered_object_offset

		if hovered_object.name.find("Food") > -1:
			hovered_object.rect_rotation = rand_range(-10, 10)

			if hovered_object.is_healthy:
				pass

			if !hovered_object.is_healthy:
				pass

		if hovered_object.name.find("Paper") > -1:
			var clamped_x = clamp(hovered_object.rect_position.x, MinPosPaper.position.x - hovered_object_offset.x, MaxPosPaper.position.x - hovered_object_offset.x)
			var clamped_y = clamp(hovered_object.rect_position.y, MinPosPaper.position.y - hovered_object_offset.y, MaxPosPaper.position.y - hovered_object_offset.y)
			hovered_object.rect_position = Vector2(clamped_x, clamped_y)
			hovered_object.rect_rotation = rand_range(-5, 5)

	if is_intro && is_game_started:
		if Input.is_action_just_pressed("ui_select") && !get_tree().paused:
			is_intro = false
			if Scribbler.name_of_person == null:
				IntroAnimation.play("Intro2")
				IntroMonologue.text = "Your name please."
			else:
				start_game()
#		IntroSkip.show()
	else:
		IntroSkip.hide()

	if is_game_started && !get_tree().paused:
		if Input.is_action_just_pressed("ui_cancel"):
			if !MenuAnimation.is_playing():
				MenuAnimation.play("To Menu")


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			is_picking = true
		else:
			is_picking = false
			hovered_object = null


func play_music(which_music):
	for i in MusicList.size():
		MusicList[i].stop()

	if !MusicList[which_music].playing:
		MusicList[which_music].play()

	current_music = MusicList[which_music]


func new_game():
	TitleSprite.hide()
	is_game_started = true
	if is_intro:
		IntroAnimation.play("Intro1")
		play_music(1)
	else:
		start_game()


func pause_game_toggle():
	if !is_game_over:
		get_tree().paused = !get_tree().paused
	else:
		get_tree().paused = true

	if !get_tree().paused:
		IntroSkip.hide()

	if is_gameplay_started:
		GameOverPoem.bbcode_text = ""
		if last_poem != null:
			GameOverPoem.bbcode_text += "[center]OH MY "
			GameOverPoem.bbcode_text += Scribbler.get_next_adjective().to_upper() + " " + Scribbler.name_of_person.to_upper()
			GameOverPoem.bbcode_text += "![/center]"
			GameOverPoem.bbcode_text += "\n\n\n"
			for i in last_poem.size():
				GameOverPoem.bbcode_text += "[center]"
				GameOverPoem.bbcode_text += last_poem[i]
				GameOverPoem.bbcode_text += "[/center]\n"

	if is_game_over:
#		GameOverPoem.bbcode_text = ""
		DeadlineTimer.stop()
#		if last_poem != null:
#			GameOverPoem.bbcode_text += "[center]OH MY "
#			GameOverPoem.bbcode_text += Scribbler.get_next_adjective().to_upper() + " " + Scribbler.name_of_person.to_upper()
#			GameOverPoem.bbcode_text += "![/center]"
#			GameOverPoem.bbcode_text += "\n\n\n"
#			for i in last_poem.size():
#				GameOverPoem.bbcode_text += "[center]"
#				GameOverPoem.bbcode_text += last_poem[i]
#				GameOverPoem.bbcode_text += "[/center]\n"
		play_music(3)


func from_menu():
	if !is_game_started:
		new_game()
	else:
		pause_game_toggle()

	if is_intro:
		play_music(1)
	if is_gameplay_started:
		play_music(2)
	if is_game_over:
		play_music(3)


func to_menu():
	pause_game_toggle()
	if !is_game_over:
		play_music(0)


func start_game():
	IntroMonologue.hide()
	get_node("IntroName").hide()
	IntroNameLabel.hide()
	IntroAnimation.stop()

	play_music(2)

	Scribbler.start_writing()
	Scribbler.get_node("Arm_L/Hand_L/Pencil").show()
	Scribbler.get_node("Paper").show()
	FoodSpawner.start_spawning()
	is_game_started = true
	is_gameplay_started = true
	is_intro = false
	Poem.show()
	HealthBar.show()
	MoodBar.show()
	StomachBar.show()
	FundsLabel.show()
	ReputationLabel.show()
	DeadlineLabel.show()
	DeadlineTimer.start()


func stop_game():
	Scribbler.stop_writing()
	Scribbler.get_node("Arm_L/Hand_L/Pencil").hide()
	Scribbler.get_node("Paper").hide()
	FoodSpawner.stop_spawning()
	is_game_started = false
	is_gameplay_started = false
	Poem.hide()
	HealthBar.hide()
	MoodBar.hide()
	StomachBar.hide()
	FundsLabel.hide()
	ReputationLabel.hide()
	DeadlineLabel.hide()
	DeadlineTimer.stop()


func _on_picked_up(node, offset):
	hovered_object = node
	hovered_object_offset = offset
	emit_signal("something_held", hovered_object)


func _on_Paper_displayed_poem(poem, is_displaying):
	displayed_text_array = poem

	for i in displayed_text_array.size():
		Poem.bbcode_text += "[center]"
		Poem.bbcode_text += displayed_text_array[i]
		Poem.bbcode_text += "[/center]\n"

	if !is_displaying:
		Poem.bbcode_text = ""


func _on_Scribbler_health_changed(health):
	HealthBar.value = health
	if health <= 0:
		get_node("DeadlineTimer").stop()


func _on_Scribbler_stomach_changed(stomach):
	StomachBar.value = stomach


func _on_Scribbler_mood_changed(mood, is_increasing):
	MoodBar.value = mood
	if is_increasing:
		MoodBar.get_node("Sprite").texture = preload("res://sprites/icon_happy.png")
	else:
		MoodBar.get_node("Sprite").texture = preload("res://sprites/icon_angry.png")


func _on_Scribbler_funds_spent(funds):
	current_funds -= funds
	FundsLabel.text = "FUNDS: $" + String(current_funds)


func _on_DeadlineTimer_timeout():
	if days_to_deadline > 1:
		days_to_deadline -= 1
		DeadlineLabel.text = "Next deadline: " + String(days_to_deadline) + " days!"
		if days_to_deadline <= 3:
			Scribbler.set_writing_speed(Scribbler.get_writing_speed() + 0.5)
	else:
		Scribbler.set_writing_speed(1)
		days_to_deadline = randi() % prev_days_to_deadline + prev_days_to_deadline
		DeadlineLabel.text = "Deadline: PUBLISHING NOW!"

		var score_from_current_published = 0
		for i in range(paper_compiled.size()):
			score_from_current_published += paper_compiled[i].score
			paper_compiled[i].target_pos = Vector2(rand_range(600, 800), -200)
			randomize()
			paper_compiled[i].lerp_speed = rand_range(1, 5)
#			paper_compiled[i].set_process(true)
#			paper_compiled[i].queue_free()
		paper_compiled = []

		reputation += score_from_current_published

		if reputation > 1000:
			reputation_nickname = REPUTATION_NICKNAMES[0]
			salary = ceil(rand_range(2000, 2500))
		elif reputation > 500:
			reputation_nickname = REPUTATION_NICKNAMES[1]
			salary = ceil(rand_range(1000, 2000))
		elif reputation > 300:
			reputation_nickname = REPUTATION_NICKNAMES[2]
			salary = ceil(rand_range(500, 1000))
		elif reputation > 100 && reputation > -100:
			reputation_nickname = REPUTATION_NICKNAMES[3]
			salary = ceil(rand_range(200, 500))
		elif reputation < -100:
			reputation_nickname = REPUTATION_NICKNAMES[4]
			salary = ceil(rand_range(100, 200))
		elif reputation < -300:
			reputation_nickname = REPUTATION_NICKNAMES[5]
			salary = ceil(rand_range(50, 100))
		elif reputation < -500:
			reputation_nickname = REPUTATION_NICKNAMES[6]
			salary = ceil(rand_range(1, 50))

		reputation_nickname = reputation_nickname.to_upper()

		ReputationLabel.text = "YOUR REPUTATION: " + String(reputation) + " (" + reputation_nickname + ")"

		current_funds += salary
		FundsLabel.text = "FUNDS: $" + String(current_funds)

var intro_scribbler_health = 0
var intro_scribbler_mood = 0
var intro_scribbler_stomach = 0

func intro_spawn_food(spawned):
	randomize()
	var food
	if spawned == 0:
		food = preload("res://UnhealthyFood.tscn").instance()
	if spawned == 1:
		food = preload("res://HealthyFood.tscn").instance()
	add_child(food)

	var width = get_viewport_rect().size.x
	var height = get_viewport_rect().size.y

	var random_x = rand_range(width - 200, width - 70)
	var random_y = rand_range(height - 100, height - 200)

	food.food_points = food.food_grade * rand_range(5, 10)
	food.rect_position = Vector2(random_x, random_y)
	food.move_speed = 0

	intro_scribbler_health = Scribbler.health
	intro_scribbler_mood = Scribbler.mood
	intro_scribbler_stomach = Scribbler.stomach

	if Scribbler.stomach >= Scribbler.MAX_STOMACH:
		Scribbler.stomach -= 50
	Scribbler.get_node("FeedingArea").monitoring = true
	Scribbler.get_node("FeedingArea").monitorable = true

	IntroTimer.start()


func intro_say_thanks_name():
	IntroMonologue.text = "Thank you, " + Scribbler.name_of_person + "!"
	Scribbler.play_sfx(3)

	if !Scribbler.EatingAnimation.is_playing():
		Scribbler.EatingAnimation.play("Eating")

	if IntroAnimation.current_animation != "Intro1" && IntroAnimation.current_animation != "Intro2":
		if !Scribbler.WritingAnimation.is_playing():
			Scribbler.WritingAnimation.play("Talking")


func intro_say(text):
	IntroMonologue.text = text
	Scribbler.play_sfx(3)

	if !Scribbler.EatingAnimation.is_playing():
		Scribbler.EatingAnimation.play("Eating")

	if IntroAnimation.current_animation != "Intro1" && IntroAnimation.current_animation != "Intro2":
		if !Scribbler.WritingAnimation.is_playing():
			Scribbler.WritingAnimation.play("Talking")
			print("Yoba yoba")


func intro_next(anim):
	IntroAnimation.play(anim)


func _on_IntroName_text_entered(new_text):
	Scribbler.name_of_person = new_text

	if is_intro:
		IntroAnimation.play("Intro3")
	else:
		IntroAnimation.stop()
		start_game()


func _on_IntroName_text_changed(new_text):
	if new_text == "":
		IntroMonologue.text = ""
	else:
		IntroMonologue.text = "So you're called " + new_text + "?"
		Scribbler.play_sfx(3)

		if !Scribbler.EatingAnimation.is_playing():
			Scribbler.EatingAnimation.play("Eating")

		if IntroAnimation.current_animation != "Intro1" && IntroAnimation.current_animation != "Intro2":
			if !Scribbler.WritingAnimation.is_playing():
				Scribbler.WritingAnimation.play("Talking")


func _on_IntroTimer_timeout():
	if intro_scribbler_mood < Scribbler.mood:
		IntroTimer.stop()
		IntroAnimation.play("Intro4")

	if intro_scribbler_health < Scribbler.health:
		IntroAnimation.play("Intro5")
		IntroTimer.stop()


func _on_MusicTimer_timeout():
	if !current_music.playing:
		current_music.play()
