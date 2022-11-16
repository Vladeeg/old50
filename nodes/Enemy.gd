extends KinematicBody

export var HP = 100
export var attack_time = 2
export var stand_time = 2
export (PackedScene) var projectile
export var speed = 0.1

var attack_timer = attack_time + rand_range(0, 2)

var gravity = -30
var hurt_timer = 0
var attack_anim_timer = 0
var stand_timer = 0
var velocity = Vector3.ZERO

export (String) var move_strat = "follow"

var moving = 0
var to_coords
var dir = Vector3()

var map: Array
var player: KinematicBody
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func bruh(dmg):
	HP -= dmg
	hurt_timer = 0.5
	$AnimatedSprite3D.animation = "Hurt"
	if HP <= 0:
		player.killed += 1
		$DeadSound.play()
		queue_free()

func _choose_cell():
	var pos = global_transform.origin
	var map_pos = { x = floor(pos.x / 2), y = ceil(pos.z / 2)}
	
	var near_cells = []
		
	var start_x = clamp(map_pos.x - 1, 0, len(map))
	var start_y = clamp(map_pos.y - 1, 0, len(map[0]))
	var end_x = clamp(map_pos.x + 1, 0, len(map))
	var end_y = clamp(map_pos.y + 1, 0, len(map[0]))
	for i in range(start_x, end_x):
		for j in range(start_y, end_y):
#			if map[i][j] == ".":
			near_cells.push_back({ x = i, y = j })
	if len(near_cells) > 0:
		return near_cells[rand_range(0, len(near_cells))]
	else: return map_pos

func _physics_process(delta):
	dir = Vector3()
	var space_state = get_world().direct_space_state
	var player_intersection = space_state.intersect_ray(global_transform.origin,
			player.global_transform.origin, [self])
	
	if not move_strat == "standing":
		if moving <= 0 and stand_timer <= 0:
			var to_cell = _choose_cell()
			to_coords = Vector3(
				(to_cell.x * 2) + rand_range(0, 1),
				0,
				(to_cell.y * 2) + rand_range(0, 1)
			)
			moving = 2
	
		if moving > 0:
			moving -= delta 
			var vec: Vector3 = to_coords - global_transform.origin
			vec.y = 0
			if vec.length() > 0:
				dir += vec
			else:
				stand_timer = rand_range(0, stand_time)
				moving = 0

	stand_timer -= delta

#	if stand_timer <= 0:
#		stand_timer = rand_range(0, stand_time)
#	stand_timer -= delta

	if player_intersection and player_intersection.collider_id == player.get_instance_id():
		var o = global_transform.origin + Vector3(0, 1.5, 0)
		if attack_timer <= 0:
			$DeadSound.play()
			$AnimatedSprite3D.play("Attack")
			var p = projectile.instance()
			p.transform.origin = o
			p.direction = player.global_transform.origin - o
			get_parent().add_child(p)
			attack_anim_timer = 0.3
			attack_timer = attack_time + rand_range(0, 2)
	
		if move_strat == "follow":
			dir += player.global_transform.origin - o
		

	dir.y = 0
	velocity += dir.normalized() * speed
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var a = $AnimatedSprite3D.animation
	if hurt_timer < 0 and a == "Hurt":
		$AnimatedSprite3D.animation = "Idle"
		hurt_timer = 0
	hurt_timer -= delta
	if attack_anim_timer < 0 and a == "Attack":
		$AnimatedSprite3D.animation = "Idle"
		attack_anim_timer = 0
	attack_anim_timer -= delta

	attack_timer -= delta
