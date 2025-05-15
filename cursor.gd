class_name Cursor extends Node3D

@export var cursor_scroll_speed: float = 30.0

@export var received_mouse_input_last: bool = false

@onready var cursor_point: Node3D = $CursorPoint

var cursor_point_location: Vector3:
	get:
		return cursor_point.global_position

const INPUT_SWITCH_DEADZONE: float = 0.2
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		var motion_data := (event as InputEventJoypadMotion)
		var axis := motion_data.axis
		var strength := motion_data.axis_value
		if strength >= INPUT_SWITCH_DEADZONE and (axis == JOY_AXIS_LEFT_X or axis == JOY_AXIS_LEFT_Y):
			received_mouse_input_last = false
	elif event is InputEventMouseMotion:
		received_mouse_input_last = true
	
func _process_cursor_movement(delta: float) -> void:
	var input_directions: Vector2 = Input.get_vector("cursor_left", "cursor_right", "cursor_backward", "cursor_forward")
	
	position += Vector3(input_directions.x, 0.0, input_directions.y * -1.0) * cursor_scroll_speed * delta

func _process_mouse_movement(delta: float) -> void:
	if not received_mouse_input_last:
		cursor_point.position = lerp(Vector3.ZERO, cursor_point.position, exp( -8.0 * delta ))
		return
	
	var current_viewport := get_viewport()
	if current_viewport == null:
		return
		
	var current_camera := current_viewport.get_camera_3d()
	if current_camera == null:
		return
	
	var mouse_position := current_viewport.get_mouse_position()
	var gameplay_plane := Plane(Vector3.UP)
	var one_step_forward := (current_camera.project_position(mouse_position, 1.0) - current_camera.global_position).normalized()
	var intersection_point = gameplay_plane.intersects_ray(current_camera.global_position, one_step_forward)
	if intersection_point is Vector3:
		cursor_point.global_position = intersection_point
	else:
		cursor_point.position = Vector3.ZERO

func _ready() -> void:
	received_mouse_input_last = false

func _process(delta: float) -> void:
	_process_cursor_movement(delta)
	_process_mouse_movement(delta)
