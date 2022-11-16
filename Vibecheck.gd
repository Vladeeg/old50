extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MAX_HP = 100
var HP = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Path2D/PathFollow2D.unit_offset = 1 - (HP / MAX_HP)
	$vibecheck.position = $Path2D/PathFollow2D.position
	$Path2D2/PathFollow2D.unit_offset = 1 - (HP / MAX_HP)
	$vibecheck2.position = $Path2D2/PathFollow2D.position
	pass
