extends Node2D

const FOODSCN_LIST = [preload("res://UnhealthyFood.tscn"), preload("res://HealthyFood.tscn")]

onready var Timer = get_node("Timer")


func _ready():
	Timer.stop()


func start_spawning():
	Timer.start()


func stop_spawning():
	Timer.stop()


func spawn_food():
	randomize()
	var food = FOODSCN_LIST[randi() % FOODSCN_LIST.size()].instance()
	get_parent().add_child(food)

	var width = get_viewport_rect().size.x
	var height = get_viewport_rect().size.y

	var random_x = rand_range(width - 200, width - 70)
	var random_y = rand_range(height + 50, height + 100)

	food.food_points = food.food_grade * rand_range(5, 10)
	food.rect_position = Vector2(random_x, random_y)


func _on_Timer_timeout():
	spawn_food()
