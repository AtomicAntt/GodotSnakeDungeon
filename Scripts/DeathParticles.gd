extends Particles2D

onready var wizard = preload("res://Assets/FireWizardIdle.png")
onready var warrior = preload("res://Assets/Warrior.png")
onready var body = preload("res://Assets/Body.png")
onready var head = preload("res://Assets/Head.png")

var type = 1

func _ready():
	if type == 1:
		self.set_texture(warrior)
	elif type == 2:
		self.set_texture(wizard)
	elif type == 3:
		self.set_texture(body)
	elif type == 4:
		self.set_texture(head)
	$AnimationPlayer.play("play")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "play":
		queue_free()
