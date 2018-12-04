extends Node2D

signal health_changed(health)
signal stomach_changed(stomach)
signal mood_changed(mood, is_increasing)
signal funds_spent(funds)

const PaperScn = preload("res://Paper.tscn")

const MouthDefault = preload("res://sprites/mouth.png")
const MouthDrool = preload("res://sprites/mouth_drool.png")
const MouthEat = preload("res://sprites/mouth_eat.png")

const positive = "res://positive_adjectives.txt"
const negative = "res://negative_adjectives.txt"
const nouns = "res://nouns.txt"
const verbs = "res://verbs.txt"

onready var MoneyWhereSprites = [get_node("MoneyWhere1"), get_node("MoneyWhere2"), get_node("MoneyWhere3")]

onready var WritingAnimation = get_node("WritingAnimation")
onready var WrittenAnimation = get_node("WrittenAnimation")
onready var EatingAnimation = get_node("EatingAnimation")
onready var DyingAnimation = get_node("DyingAnimation")

onready var HealthCheckTimer = get_node("HealthCheckTimer")
onready var StomachTimer = get_node("StomachTimer")
onready var MoodTimer = get_node("MoodTimer")
onready var MoodSwingTimer = get_node("MoodSwingTimer")

onready var MinPosPaper = get_parent().get_node("MinPosPaper")
onready var MaxPosPaper = get_parent().get_node("MaxPosPaper")

onready var Mouth = get_node("Body/Head/Mouth")

onready var ScribblerSprites = [
	get_node("Body"),
	get_node("Body/Head/Mouth"),
	get_node("Body/Head"),
	get_node("Arm_L"),
	get_node("Arm_L/Hand_L"),
	get_node("Arm_R"),
	get_node("Arm_R/Hand_R")
]

onready var Sfx = [get_node("SfxEat"),
				   get_node("SfxDrool"),
				   get_node("SfxEeeww"),
				   get_node("SfxTalk"),
				   get_node("SfxWrite"),
				   get_node("SfxPaper")]

var current_sfx

var positive_array = []
var negative_array = []
var nouns_array = []
var verbs_array = []
var name_of_person

var stitched_sentences = []
var calculated_score = 0

const MAX_HEALTH = 100
const MAX_STOMACH = 100
const MAX_MOOD = 100
const MIN_MOOD = -MAX_MOOD

var health = 100.0
var stomach = 100.0
var mood = 50.0
var prev_mood = 0.0
var is_mood_increasing = false

var last_food_points = 1.0

var is_writing = false

var next_paper_cost = 0

func _ready():
	if !is_connected("health_changed", get_parent(), "_on_Scribbler_health_changed"):
		connect("health_changed", get_parent(), "_on_Scribbler_health_changed")
#	emit_signal("health_changed", health)

	if !is_connected("stomach_changed", get_parent(), "_on_Scribbler_stomach_changed"):
		connect("stomach_changed", get_parent(), "_on_Scribbler_stomach_changed")
#	emit_signal("stomach_changed", stomach)

	if !is_connected("mood_changed", get_parent(), "_on_Scribbler_mood_changed"):
		connect("mood_changed", get_parent(), "_on_Scribbler_mood_changed")
#
	if !is_connected("funds_spent", get_parent(), "_on_Scribbler_funds_spent"):
		connect("funds_spent", get_parent(), "_on_Scribbler_funds_spent")

#	start_writing()
	positive_array = load_file(positive)
	negative_array = load_file(negative)
	nouns_array = load_file(nouns)
	verbs_array = load_file(verbs)


func play_sfx(which_sfx):
	for i in Sfx.size():
		Sfx[i].stop()

	if !Sfx[which_sfx].playing:
		Sfx[which_sfx].play()

	current_sfx = Sfx[which_sfx]


func play_SfxWrite(can_play):
	if can_play:
		if !Sfx[4].is_playing():
			Sfx[4].play()
	else:
		Sfx[4].stop()


func start_writing():
	WritingAnimation.play("Writing")
	WrittenAnimation.play("Written")
	HealthCheckTimer.start()
	StomachTimer.start()
	MoodTimer.start()
	get_node("FeedingArea").monitoring = true
	get_node("FeedingArea").monitorable = true
	is_writing = true


func stop_writing():
	WritingAnimation.stop()
	WrittenAnimation.stop()
	HealthCheckTimer.stop()
	StomachTimer.stop()
	MoodTimer.stop()
	MoodSwingTimer.stop()
	get_node("FeedingArea").monitoring = false
	get_node("FeedingArea").monitorable = false
	is_writing = false


func set_writing_speed(speed):
	WritingAnimation.playback_speed = speed
	WrittenAnimation.playback_speed = speed


func get_writing_speed():
	return WritingAnimation.playback_speed


func resume_from_out_of_funds():
	if get_parent().current_funds >= next_paper_cost:
		start_writing()


func on_written():
	WritingAnimation.stop()
	var Paper = PaperScn.instance()
	get_parent().add_child(Paper)
	var random_x = rand_range(MinPosPaper.position.x, MaxPosPaper.position.x)
	var random_y = rand_range(MinPosPaper.position.y, MaxPosPaper.position.y)
	Paper.rect_position = Vector2(random_x, random_y)
	Paper.rect_rotation = rand_range(-10, 10)
	Paper.poem = stitched_sentences
	Paper.score = calculated_score
	Paper.show_written_lines(Paper.poem.size())

	if !get_parent().is_connected("paper_compiled", Paper, "_on_paper_compiled"):
		get_parent().connect("paper_compiled", Paper, "_on_paper_compiled")

	next_paper_cost = Paper.paper_cost
	emit_signal("funds_spent", Paper.paper_cost)

	# TODO: save stitched sentences

	stitched_sentences = []
	calculated_score = 0

	if get_parent().current_funds >= Paper.paper_cost:
		start_writing()
	elif !WritingAnimation.is_playing():
		WritingAnimation.play("Out of Funds")

	if !Sfx[5].is_playing():
		Sfx[5].play()


func write_sentence():
	stitched_sentences.push_back(get_next_sentence())
	if mood < 0 && randf() * mood > mood * 0.8:
		on_written()


func get_rand_positive():
	randomize()
	return positive_array[randi() % positive_array.size()]


func get_rand_negative():
	randomize()
	return negative_array[randi() % negative_array.size()]


func get_rand_noun():
	randomize()
	return nouns_array[randi() % nouns_array.size()]


func get_rand_verb():
	randomize()
	return verbs_array[randi() % verbs_array.size()]


func get_next_adjective():
	if is_mood_increasing || mood > 0:
		calculated_score += 1
		return get_rand_positive()
	elif !is_mood_increasing:
		calculated_score -= 1
		return get_rand_negative()


func get_next_sentence():
	var next_sentence = ""
	var next_person = [
		name_of_person,
		"It",
		"They",
		"He",
		"She",
		"We"
	]
	var next_in_between = [
		"has",
		"have",
		"has been",
		"have been",
		"haven't",
		"hasn't",
		"such",
		"is",
		"are",
		"thou",
		"does",
		"doesn't",
		"don't",
		"do",
		"thy",
		"not",
		"no"
	]
	var next_connector = [
		"and",
		"so",
		"but",
		"or",
		"for",
		"because",
		"on"
	]
	var next_ask = [
		"what",
		"why",
		"who",
		"whose",
		"how",
		"when"
	]
	var next_punct = [
		". ",
		"! ",
		", ",
		": ",
		"; ",
		"? ",
		"-",
	]
	var next_dramatic = [
		"Oh my",
		"I beg thee",
		"No need",
		"No more",
		"I swear",
		"No way",
		"Maybe",
		"No matter",
		"Literally",
		"Surprisingly",
		"Hilariously",
		"Never ever",
		"Ever after",
		"A plethora of",
		"Please!",
		"Sacrifices must be made!",
		"Sacrifices must be made!",
		"Sacrifices must be made!",
		"Sacrifices must be made!",
		"Sacrifices must be made!",
		"Sacrifices must be made!"
	]

	randomize()
	var next_rand_person = next_person[randi() % next_person.size()]
	var next_rand_in_between = next_in_between[randi() % next_in_between.size()]
	var next_rand_connector = next_connector[randi() % next_connector.size()]
	var next_rand_ask = next_ask[randi() % next_ask.size()]
	var next_rand_punct = next_punct[randi() % next_punct.size()]
	var next_rand_dramatic = next_dramatic[randi() % next_dramatic.size()]

	var next_possible_sentence = [
		next_rand_in_between + " " + get_next_adjective() + " " + next_rand_person + next_rand_punct,
		next_rand_person + " " + next_rand_in_between + " " + get_next_adjective() + " " + next_rand_connector + " " + next_rand_person + " " + next_rand_in_between + " " + get_rand_noun() + next_rand_punct,
		next_rand_ask + " " + next_rand_in_between + " " + get_rand_verb() + " " + next_rand_connector + " " + next_rand_person + " " + next_rand_in_between + " " + get_rand_noun() + next_rand_punct,
		next_rand_dramatic + " " + get_next_adjective() + " "  + name_of_person + "! " + next_rand_ask + " " + next_rand_in_between + " " + next_rand_person + " " + get_rand_verb() + "? ",
		next_rand_connector + " " + next_rand_ask + " " + next_rand_in_between + " " + next_rand_person + " " + next_rand_dramatic + ": " + next_rand_person + " " + next_rand_connector + " " + next_rand_dramatic + " " + get_next_adjective() + " " + get_rand_noun() + next_rand_punct,
		next_rand_dramatic + " " + next_rand_person + " " + next_rand_ask + " " + next_rand_in_between + " " + get_next_adjective() + " " + get_rand_noun() + next_rand_punct,
		"The quick " + get_next_adjective() + " " + get_rand_noun() + " " + get_rand_verb() + " over the " + get_next_adjective() + " " + get_next_adjective() + " " + get_rand_noun() + next_rand_punct,
		next_rand_ask + " did the " + get_rand_noun() + " " + get_rand_verb() + " the " + get_rand_noun() + "?",
	]

	randomize()
	next_sentence = next_possible_sentence[randi() % next_possible_sentence.size()]

	next_sentence = next_sentence.to_upper()
	return next_sentence


func load_file(filename):
	var result = []
	var f = File.new()
	f.open(filename, File.READ)
	while not f.eof_reached():
		var line = f.get_line()
		result.push_back(line)
	f.close()
	return result


func modulate_ScribblerSprites(color):
	for i in range(ScribblerSprites.size()):
		ScribblerSprites[i].modulate = color


func _on_HealthCheckTimer_timeout():
	var value = health / MAX_HEALTH
	modulate_ScribblerSprites(Color(1, 1, value, 1))

	if health <= 0:
		stop_writing()
		DyingAnimation.play("Die")


func died():
	get_parent().MenuAnimation.play("To Menu")
	get_parent().is_game_over = true
	stop_writing()


func _on_StomachTimer_timeout():
	if stomach > 0:
		stomach -= rand_range(1, 2 * WritingAnimation.playback_speed) + 0.5
		emit_signal("stomach_changed", stomach)

	if stomach > MAX_STOMACH * 0.5:
		if health < MAX_HEALTH:
			health += last_food_points * 0.01
			emit_signal("health_changed", health)

	if stomach <= 0:
		if health > 0:
			health -= 1
			emit_signal("health_changed", health)


func _on_MoodTimer_timeout():
	if is_mood_increasing:
		if mood < MAX_MOOD:
			mood += last_food_points * 0.5

		if MoodSwingTimer.is_stopped():
			MoodSwingTimer.start()
	else:
		if mood > MIN_MOOD:
			mood -= last_food_points * 0.5
	emit_signal("mood_changed", mood, is_mood_increasing)

	if mood <= -50 && health <= 50:
		health -= last_food_points * 0.05
		emit_signal("health_changed", health)


func _on_MoodSwingTimer_timeout():
	if is_mood_increasing:
		is_mood_increasing = false
	MoodSwingTimer.wait_time = rand_range(5, 15)


func _on_FeedingArea_area_entered(area):
	var node = area.get_parent()

	if node.name.find("Food") > -1:
		if stomach < MAX_STOMACH:
			if !EatingAnimation.is_playing():
				EatingAnimation.play("Eating")
			if EatingAnimation.is_playing():
				EatingAnimation.stop()
				EatingAnimation.play("Eating")
				play_sfx(0)
			get_parent().hovered_object = null
			node.get_eaten()
			emit_signal("funds_spent", node.food_cost)

			stomach += node.food_points
			last_food_points = node.food_points
			emit_signal("stomach_changed", stomach)

			if area.get_parent().is_healthy:
				if health < MAX_HEALTH:
					health += node.food_points
				emit_signal("health_changed", health)
				prev_mood = mood
				if mood > MIN_MOOD:
					mood -= node.food_points * 0.1
					is_mood_increasing = false
				emit_signal("mood_changed", mood, is_mood_increasing)

			if !area.get_parent().is_healthy:
				if health > 0:
					health -= node.food_points
				if stomach >= MAX_STOMACH:
					health -= node.food_points
				emit_signal("health_changed", health)
				prev_mood = mood
				if mood < MAX_MOOD:
					mood += node.food_points * 0.1
					is_mood_increasing = true
				emit_signal("mood_changed", mood, is_mood_increasing)
		if stomach >= MAX_STOMACH:
			if !EatingAnimation.is_playing():
				EatingAnimation.play("Full")


func _on_something_held(thing):
	if thing.name.find("Food") > -1 && stomach < MAX_STOMACH:
		if thing.is_healthy && health > 0:
			if !EatingAnimation.is_playing():
				play_sfx(2)
				EatingAnimation.play("Don't Want")
		if !thing.is_healthy && health > 0:
			if !EatingAnimation.is_playing():
				play_sfx(1)
				EatingAnimation.play("Drooling")
