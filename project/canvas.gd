extends ColorRect

@onready var max_iterations_slider = $Controls/MaxIterations
@onready var two_slider = $Controls/Two
@onready var zoom_slider = $Controls/Zoom
@onready var x_slider = $Controls/X
@onready var y_slider = $Controls/Y

var p = Vector2(0, -0.75)
var is_dragging = false
var drag_start_p = Vector2.ZERO
var drag_start_mouse_pos = Vector2.ZERO

var is_zooming = false
const ZOOM_SPEED = 0.5

func _input(event):
	# quit when Esc is pressed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if get_node("Controls").get_rect().has_point(event.position):
				return

			is_dragging = event.is_pressed()
			if is_dragging:
				drag_start_p = p
				drag_start_mouse_pos = event.position
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if get_node("Controls").get_rect().has_point(event.position):
				return
			is_zooming = event.is_pressed()

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			handle_zoom(event.position, zoom_slider.get_value() * 0.1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			handle_zoom(event.position, zoom_slider.get_value() * -0.1)

	if event is InputEventMagnifyGesture:
		handle_zoom(event.position, zoom_slider.get_value() * (event.factor - 1.0))

	if event is InputEventMouseMotion and is_dragging:
		var zoom = zoom_slider.get_value()
		var viewport_height = get_viewport_rect().size.y
		
		if viewport_height > 0:
			var mouse_delta = event.position - drag_start_mouse_pos
			p = drag_start_p - (mouse_delta / viewport_height) / exp(zoom - 1.25)
			
			x_slider.set_value(p.x)
			y_slider.set_value(p.y)

func handle_zoom(mouse_pos, zoom_delta):
	var zoom_before = zoom_slider.get_value()
	var zoom_after = zoom_before + zoom_delta
	
	if zoom_after == zoom_before:
		return

	var viewport_size = get_viewport_rect().size
	if viewport_size.y <= 0:
		return
		
	var ratio = viewport_size.x / viewport_size.y
	
	var uv_norm_x = (mouse_pos.x / viewport_size.x - 0.5) * ratio
	var uv_norm_y = (mouse_pos.y / viewport_size.y - 0.5)
	var uv_norm = Vector2(uv_norm_x, uv_norm_y)

	var p_before = p
	var p_after = p_before + uv_norm * (1 / exp(zoom_before - 1.25) - 1 / exp(zoom_after - 1.25))

	p = p_after
	x_slider.set_value(p.x)
	y_slider.set_value(p.y)
	zoom_slider.set_value(zoom_after)

func _process(_delta):
	if is_zooming:
		handle_zoom(get_viewport().get_mouse_position(), ZOOM_SPEED * _delta)

	p.x = x_slider.get_value()
	p.y = y_slider.get_value()
	
	var viewport_size = get_viewport_rect().size
	if viewport_size.y > 0:
		var ratio = viewport_size.x / viewport_size.y
		$".".material.set("shader_parameter/ratio", ratio)

	# update shader params
	$".".material.set("shader_parameter/position", p)
	$".".material.set("shader_parameter/zoom", zoom_slider.get_value())
	$".".material.set("shader_parameter/tiq", two_slider.get_value())
	$".".material.set("shader_parameter/iteration_limit", max_iterations_slider.get_value())
