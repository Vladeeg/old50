extends KinematicBody

export var gravity = -30.0
export var walk_speed = 8.0
export var run_speed = 16.0
export var jump_speed = 10.0
export var mouse_sensitivity = 0.002
export var acceleration = 4.0
export var friction = 6.0
export var fall_limit = -1000.0

export var HP = 100.0
export var HP_drain_rate = 2
var healing = false
var shooting = false

var pivot
var killed = 0

onready var raycast = $pivot/camera/RayCast

var playable = true
var dir = Vector3.ZERO
var velocity = Vector3.ZERO


func _ready():
	pivot = $pivot
	$pivot/camera/OmniLight.light_energy = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var razyob = Vector2(0.5, 0.5)
var displacement = 0
var hurted = false
func hurt(dmg):
	displacement += razyob.y
	rotate_y(razyob.y)
	pivot.rotate_x(razyob.x)
	pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)
	$HurtSound.play()
	HP -= dmg

func _physics_process(delta):
	if displacement > 0:
		displacement -= 2 * delta * (razyob.y)
		rotate_y(-2 * delta*razyob.y)
		pivot.rotate_x(-2 * delta*razyob.x)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)

	dir = Vector3.ZERO
	var basis = global_transform.basis
	if Input.is_action_pressed("move_forward"):
		dir -= basis.z
	if Input.is_action_pressed("move_back"):
		dir += basis.z
	if Input.is_action_pressed("move_left"):
		dir -= basis.x
	if Input.is_action_pressed("move_right"):
		dir += basis.x
	dir = dir.normalized()
	
#	shot_timer -= delta
	if not shooting:
		$UserInterface/Gun.animation = "default"
#		$pivot/camera/OmniLight.light_energy = 0
#		shot_timer = 0
	if Input.is_action_just_pressed("shoot"):
		if not shooting:
			$AudioStreamPlayer.play()
			$UserInterface/Gun.play("shot")
			$pivot/camera/OmniLight.light_energy = 2
			$Tween.interpolate_property($pivot/camera/OmniLight, "light_energy",
				2, 0, 0.2,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
			$UserInterface/Gun.speed_scale = 1
			shooting = true
			var obj = raycast.get_collider()
			if obj and obj.is_in_group("mob"):
				obj.bruh(34)
#		var block_global_position = (position - normal / 2).floor()
	

	var speed = walk_speed
	if is_on_floor():
		#this prevents you from sliding without messing up the is_on_ground() check
		velocity.y += gravity * delta / 100.0
		if Input.is_action_pressed("run"):
			speed = run_speed
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
	else:
		velocity.y += gravity * delta

	var hvel = velocity
	hvel.y = 0.0

	var target = dir * speed
	var accel
	if dir.dot(hvel) > 0.0:
		accel = acceleration
	else:
		accel = friction
	hvel = hvel.linear_interpolate(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	if playable:
		velocity = move_and_slide(velocity, Vector3.UP, true)

	if HP > 0 and not healing:
		HP -= HP_drain_rate * delta
		pass
	if HP <= 0 and playable:
		playable = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		fader._fade_start("main_menu")
	if HP > 100:
		HP = 100

	if abs(velocity.x) > 0.1 or abs(velocity.z) > 0.1:
		$UserInterface/Gun.playing = true
		if $UserInterface/Gun.animation == "shot":
			$UserInterface/Gun.speed_scale = 1
		else:
			$UserInterface/Gun.speed_scale = Vector2(velocity.x, velocity.z).length() / walk_speed
	elif $UserInterface/Gun.animation != "shot":
		$UserInterface/Gun.playing = false

	#prevents infinite falling
	if translation.y < fall_limit and playable:
		playable = false
		fader._reload_scene()

func _input(event):
	if event.is_action_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and playable:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)

var fadestarted = false
func _process(delta):
	if killed >= 5 and not fadestarted:
		fadestarted = true
		var msg = $UserInterface/DoorMsg
		$Tween.interpolate_property(msg, "modulate",
			msg.modulate, Color.white, 0.25,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	$UserInterface/HUD/Counter.text = String(killed) + "/5"
	$UserInterface/TextureProgress.value = HP
	$UserInterface/Vibecheck.HP = HP

func _on_shrine_player_entered():
	HP = 100

func _on_door_player_entered():
	if killed >= 5:
		$UserInterface/DoorMsg
		var msg = $UserInterface/DoorMsg;
		$WinSound.play()
		fader._reload_scene()

func _on_shrine_player_exited():
	healing = false



func _on_Gun_animation_finished():
	if $UserInterface/Gun.animation == "shot":
		shooting = false
		$UserInterface/Gun.play("default")
	pass # Replace with function body.


func _on_Tween_tween_completed(object, key):
	if key == ":modulate":
		$Timer.start(2)
	pass # Replace with function body.


func _on_Timer_timeout():
	var msg = $UserInterface/DoorMsg
	$Tween.interpolate_property(msg, "modulate",
		msg.modulate, Color(0.0, 0.0, 0.0, 0.0), 0.25,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	pass # Replace with function body.
