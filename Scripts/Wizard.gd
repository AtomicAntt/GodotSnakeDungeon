extends Area2D

var charging = false
var pelletNum = 3
var degreeShot = 90
var arrayOfAngles = []

var positionSlot = null

onready var bullet = preload("res://GameObjects/Bullet.tscn")

func _ready():
	$AnimationPlayer.play("appear")
	if pelletNum % 2 != 0: # if the amount of pellets is odd, one angle will be 0 (3 will be som like -45, 0, 45 at 90 deg)
		pelletNum -= 1
		arrayOfAngles.append(0)
	
	var startDeg = -(degreeShot / 2) # -45
	for i in range(pelletNum):
		arrayOfAngles.append(startDeg)
		startDeg += (degreeShot / pelletNum)
		if startDeg == 0:
			startDeg += (degreeShot/pelletNum)

func _physics_process(delta):
	var player = get_tree().get_nodes_in_group("player")[0]
	var dir = position.direction_to(player.midPoint)
	
	if dir.x <	0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false	
	
	if not charging:
		$AnimatedSprite.play("Idle")
	elif charging:
		$AnimatedSprite.play("Charge")

func _on_ChargeTimer_timeout():
	# When charge timer ends from start of game or from shooting
	charging = true
	$ShootTimer.start()

func _on_ShootTimer_timeout():
	# When shoot timer ends from charging, wait to START charging again and at the end of that charge it calls this and ends anim and also shoots
	charging = false
	$ChargeTimer.start()
	$Fire.play()
	var player = get_tree().get_nodes_in_group("player")[0]
	var dir = position.direction_to(player.midPoint)
	for angle in arrayOfAngles:
		var radians = deg2rad(angle)
		var bulletInstance = bullet.instance()
		bulletInstance.rotation = dir.rotated(radians).angle()
		bulletInstance.position = position
		get_parent().add_child(bulletInstance)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "appear":
		charging = true
		$ShootTimer.start()
