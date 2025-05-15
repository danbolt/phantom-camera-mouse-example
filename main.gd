class_name Main extends Node3D

@onready var look_spot: Node3D = $LookSpot
@onready var mouse_spot: Node3D = $LookSpot/MouseSpot

@onready var camera: PhantomCamera3D = $PhantomCamera3D

const SCROLL_SPEED: float = 4.0

func process_mouse_movement() -> void:
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
		mouse_spot.global_position = intersection_point
	else:
		mouse_spot.position = Vector3.ZERO

func process_input(delta: float) -> void:
	look_spot.position += (Vector3.RIGHT * Input.get_axis("ui_left", "ui_right")) * delta * SCROLL_SPEED
	look_spot.position += (Vector3.FORWARD * Input.get_axis("ui_down", "ui_up")) * delta * SCROLL_SPEED

func _ready() -> void:
	camera.set_look_at_target(look_spot)
	camera.set_follow_target(look_spot)

func _process(delta: float) -> void:
	process_input(delta)
	process_mouse_movement()
