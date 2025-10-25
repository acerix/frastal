extends ColorRect

@onready var max_iterations_slider = $Controls/MaxIterations
@onready var two_slider = $Controls/Two
@onready var zoom_slider = $Controls/Zoom
@onready var x_slider = $Controls/X
@onready var y_slider = $Controls/Y
@onready var palette_flow_widget = $Controls/PalleteFlow

var p = Vector2.ZERO
var is_dragging = false
var drag_start_p = Vector2.ZERO
var drag_start_mouse_pos = Vector2.ZERO

var is_zooming = false
var zoom_mag = 1.0
var palette_offset = 0
var t = 0.0

func get_viewport_aspect_ratio():
	var viewport_size = get_viewport_rect().size
	if viewport_size.y == 0:
		return 1.0
	return viewport_size.x / viewport_size.y

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
			handle_zoom(event.position, zoom_mag)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			handle_zoom(event.position, -zoom_mag)

	if event is InputEventMagnifyGesture:
		handle_zoom(event.position, zoom_mag * event.factor)

	if event is InputEventMouseMotion and is_dragging:
		var zoom = zoom_slider.get_value()
		var viewport_height = get_viewport_rect().size.y
		
		if viewport_height > 0:
			var mouse_delta = event.position - drag_start_mouse_pos
			p = drag_start_p - (mouse_delta / viewport_height) / zoom
			
			x_slider.set_value(p.x)
			y_slider.set_value(p.y)

func handle_zoom(mouse_pos, zoom_delta):
	if zoom_delta == 0:
		return

	var zoom_before = zoom_slider.get_value()
	var zoom_after = zoom_before + zoom_delta

	var viewport_size = get_viewport_rect().size
	if viewport_size.y <= 0:
		return

	var viewport_aspect_ratio = get_viewport_aspect_ratio()

	var uv_centered = mouse_pos / viewport_size - Vector2(0.5, 0.5)
	var mouse_uv_norm = uv_centered * Vector2(viewport_aspect_ratio, 1.0)

	var p_before = p

	# The core idea is to keep the fractal coordinate under the mouse constant.
	# fractal_coord = p + uv_norm / zoom
	# p_before + uv_norm / zoom_before = p_after + uv_norm / zoom_after
	# p_after = p_before + uv_norm * (1/zoom_before - 1/zoom_after)
	if zoom_before != 0 && zoom_after != 0:
		p = p_before + mouse_uv_norm * (1.0/zoom_before - 1.0/zoom_after)
		x_slider.set_value(p.x)
		y_slider.set_value(p.y)

	zoom_slider.set_value(zoom_after)
	
func _process(delta):
	#var t = Time.get_unix_time_from_system()
	t += delta
	
	if is_zooming:
		handle_zoom(get_viewport().get_mouse_position(), 32 * zoom_mag * delta)

	if !is_zooming and !is_dragging:
		p.x = x_slider.get_value()
		p.y = y_slider.get_value()
	
	var viewport_aspect_ratio = get_viewport_aspect_ratio()
	$".".material.set("shader_parameter/viewport_aspect_ratio", viewport_aspect_ratio)
	
	var zoom = zoom_slider.get_value()
	zoom_mag = abs(zoom) / 8
	
	if zoom == 0:
		# reset positions when they go to ∞
		x_slider.set_step(0)
		y_slider.set_step(0)
	else:
		var translate_step = 1 / (zoom_mag * 256)
		x_slider.set_step(translate_step)
		y_slider.set_step(translate_step * viewport_aspect_ratio)
		
	var zoom_step = max(zoom_mag / 2, 0.0001)
	zoom_slider.set_step(zoom_step)
	
	var iteration_limit = max_iterations_slider.get_value()
	#iteration_limit += roundi(iteration_limit * sin(t)) + 2
	
	var palette_flow = palette_flow_widget._get_value()
	#if palette_flow != 0:
		#palette_offset += palette_flow
	palette_offset += roundi(palette_flow * sin(t / 8))

	# update shader params
	$".".material.set("shader_parameter/position", p)
	$".".material.set("shader_parameter/zoom", zoom)
	$".".material.set("shader_parameter/two_in_quotes", two_slider.get_value())
	#$".".material.set("shader_parameter/iteration_limit", max_iterations_slider.get_value())
	$".".material.set("shader_parameter/iteration_limit", iteration_limit)
	$".".material.set("shader_parameter/palette_offset", palette_offset)
