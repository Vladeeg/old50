extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var dmg = 10
export var velocity = 10
var direction = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if (direction):
		look_at(transform.origin + direction.normalized(), Vector3.UP)
		transform.origin += direction.normalized() * velocity * delta
	pass



func _on_Projectile_body_entered(body):
	if body.is_in_group("player"):
		body.hurt(dmg)
	if not body.is_in_group("mob") and not body.is_in_group("floor"):
		queue_free()
