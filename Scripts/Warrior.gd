extends Area2D

var speed = 50
var debounceSwing = false
var swinging = false
var inRange = false
var player


func _ready():
	$AnimationPlayer.play("Walk")

func _physics_process(delta):
	player = get_tree().get_nodes_in_group("player")[0]
	var direction = position.direction_to(player.midPoint)
	if direction.x < 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false

	position += direction * speed * delta

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Swing":
		swinging = false
		speed = 50
		$AnimationPlayer.play("Walk")
		if inRange:
			player.cutSegment(self)

func swingSword():
	speed = 0
	swinging = true
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("Swing")
	


func _on_Warrior_area_entered(area):
	if area.is_in_group("body"):
		inRange = true


func _on_Warrior_area_exited(area):
	if area.is_in_group("body"):
		inRange = false
	
