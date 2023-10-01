extends CanvasLayer

onready var gameManager = get_tree().get_nodes_in_group("gamemanager")[0]
onready var pause = $Pause

func _input(event):
	if event.is_action_pressed("ui_cancel") and not gameManager.playerDead:
		if get_tree().paused:
			get_tree().paused = false
			pause.visible = false
		else:
			get_tree().paused = true
			pause.visible = true
		
