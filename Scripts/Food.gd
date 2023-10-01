extends Area2D

onready var gameManager = get_tree().get_nodes_in_group("gamemanager")[0]

func _on_Food_area_entered(area):
	if area.is_in_group("head"):
		gameManager.points += 1
		print("yummy food, i ate " + str(gameManager.points))
		queue_free()
