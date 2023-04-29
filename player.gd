extends CharacterBody3D

signal launched(transform,direction)

const Letter = preload("res://Letter.tscn")
const SPEED = 8.0
const FORWARD_SPEED = -10
const FORWARD_ACCEL = -8
const JUMP_VELOCITY = 4.5
const LAUNCH_POWER = 20
const MAX_X = 5
const RELOAD_TIME = 1
const MAX_HOLD = 3

@onready var launcher = $Launcher/Launch
@onready var letter = $Launcher/Launch

var reload = 0
var loaded = null
var fireHold = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera

func _ready():
	camera = get_viewport().get_camera_3d()

func _physics_process(delta):
	
	reload -= delta
	if !letter.visible and reload <= 0:
		load_letter()
		reload = RELOAD_TIME
			
	# if I decide to do bunny hops =]
	if false:
		if not is_on_floor():
			velocity.y -= gravity * delta
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right","ui_up","ui_down")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0,0)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# forward is -z
	if velocity.z > FORWARD_SPEED:
		velocity.z += FORWARD_ACCEL * delta
	velocity.z = clamp(velocity.z,FORWARD_SPEED,0)

	move_and_slide()
	position.x = clamp(position.x,-MAX_X,MAX_X)
	
	if Input.is_action_pressed("fire") and letter.visible:
		fireHold += delta
		if fireHold > MAX_HOLD:
			fire()
			
	if Input.is_action_just_released("fire") and fireHold > 0:
		fire()

func fire():
#	var mouse = get_viewport().get_mouse_position()
#	var from = camera.project_ray_origin(mouse)
#	var dir = camera.project_ray_normal(mouse)
#	var plane_position = position + Vector3(0,0,-20)
#	var plane = Plane(Vector3(0,0,-1),plane_position)
#	var space_rid = get_world_3d().space
#	var space_state = PhysicsServer3D.space_get_direct_state(space_rid)
#	var query = PhysicsRayQueryParameters3D.create(from,dir*1000)
#	var result = space_state.intersect_ray(query)
#	var intersection = plane.intersects_ray(from,dir)
#	if result:
#		intersection = result.position
#	var aim = (intersection - launcher.position).normalized() * LAUNCH_POWER
	var aim = Vector3(1,0,-1) * LAUNCH_POWER
	launched.emit(Transform3D(letter.global_transform),aim, fireHold)
	letter.visible = false
	fireHold = 0

func load_letter():
	letter.visible = true
