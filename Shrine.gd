extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var break_anim_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if break_anim_time > 0:
		break_anim_time -= delta
	if $AnimatedSprite3D.animation == "break" and break_anim_time <= 0:
		$AnimatedSprite3D.shaded = true
		$Tween.interpolate_property($OmniLight, "light_energy",
			$OmniLight.light_energy, 0, 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		$AnimatedSprite3D.play("broken")
#	pass


func _on_trigger_area_player_entered():
	if $trigger_area.active:
		$HealSound.play()
		break_anim_time = 1.2
		$AnimatedSprite3D.play("break")
		$Timer.start(0.4)


func _on_Timer_timeout():
	$BreakSound.play();
