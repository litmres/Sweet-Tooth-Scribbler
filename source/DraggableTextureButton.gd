extends TextureButton

signal picked_up(node, offset)

var offset = Vector2()

var is_mouse_over = false

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _input(event):
	if is_mouse_over && event is InputEventMouseButton:
		raise()
		emit_signal("picked_up", self, offset)


func _on_mouse_entered():
	is_mouse_over = true


func _on_mouse_exited():
	is_mouse_over = false


func connect_picked_up_signal(target):
	if !is_connected("picked_up", target, "_on_picked_up"):
		connect("picked_up", target, "_on_picked_up")


func disconnect_picked_up_signal(target):
	if is_connected("picked_up", target, "_on_picked_up"):
		disconnect("picked_up", target, "_on_picked_up")