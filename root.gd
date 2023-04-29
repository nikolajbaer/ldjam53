extends Node3D

const Letter = preload("res://Letter.tscn")
const Dwelling = preload("res://dwelling.tscn")
const DWELLING_SZ = 20
const DWELLING_SPAWN_DIST = -100

@onready var player = $Player
@onready var withPlayer = $WithPlayer

var furthest_dwelling = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_dwellings(player.position.z,DWELLING_SPAWN_DIST)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_past()
	withPlayer.position.z = player.position.z
	if furthest_dwelling > player.position.z + DWELLING_SPAWN_DIST:
		generate_dwellings(furthest_dwelling - DWELLING_SZ,DWELLING_SPAWN_DIST)
	
func clear_past():
	for dwelling in get_tree().get_nodes_in_group("dwellings"):
		if dwelling.position.z > player.position.z + 10:
			dwelling.queue_free()
	for letter in get_tree().get_nodes_in_group("letters"):
		if letter.position.z > player.position.z + 10:
			letter.queue_free()
			
func generate_dwellings(start,distance):
	for z in range(start,start+distance,-DWELLING_SZ):
		var dwelling = Dwelling.instantiate()
		dwelling.position = Vector3(0,0,z)
		add_child(dwelling)
		var dwelling1 = Dwelling.instantiate()
		dwelling1.position = Vector3(0,0,z)
		dwelling1.rotation.y = PI
		add_child(dwelling1)
		furthest_dwelling = z

				
func _on_player_launched(global_transform, direction,power):
	var letter = Letter.instantiate()
	letter.global_transform = global_transform
	letter.sleeping = false
	letter.freeze = false
	letter.angular_velocity = Vector3(0,-10*power,-10*power)
	letter.linear_velocity = direction + Vector3(power,power,power)
	$Letters.add_child(letter)
