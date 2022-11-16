extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ray_length = 1000
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		var obj = get_collider()
#		if obj.is_in_group("mob"):
#		obj.bruh()
		print(obj.get_name())
	pass

