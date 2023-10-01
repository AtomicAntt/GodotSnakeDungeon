extends Line2D

var currentLength = 50
var point = Vector2()
var prevMousePos = Vector2()
var deltaTime = 0

onready var head = $HeadArea2D/Sprite

var collisions = []
var midPoint = Vector2()

onready var gameManager = get_tree().get_nodes_in_group("gamemanager")[0]

onready var deathParticles = preload("res://GameObjects/DeathParticles.tscn")

func _ready():
	prevMousePos = get_global_mouse_position()

func _process(delta):
	deltaTime += delta
	global_position = Vector2(0,0)
	global_rotation = 0
	if points.size() > 0:
		midPoint = get_point_position(points.size()/2)
	else:
		midPoint = get_global_mouse_position()
		
	point = get_global_mouse_position()
	if point != prevMousePos:
		head.rotation = prevMousePos.direction_to(point).angle()
	
		
	if point.distance_to(prevMousePos) > 0.1 and deltaTime > 0.01:
		deltaTime = 0
		add_point(point)
		if points.size() > 2:
			createCollision(points.size() - 2)
	
	prevMousePos = point
	
	while returnLineLength() > currentLength and points.size() > 1:
		clearCollision()
		remove_point(0)
	
	if currentLength <= 0:
		gameOver()
		gameManager.deathMessage("You starved to death!")
	
	$HeadArea2D.position = get_global_mouse_position()
	
func returnLineLength():
	var counter = 0
	var length = 0
	for i in points.size() - 1:
		if counter != 0:
			var prevPoint = get_point_position(i-1)
			var currentPoint = get_point_position(i)
			length += prevPoint.distance_to(currentPoint)
		counter += 1
	return length

func createCollision(index):
#	for i in points.size() - 1:
#		var new_shape = CollisionShape2D.new()
#		$StaticBody2D.add_child(new_shape)
#		var rect = RectangleShape2D.new()
#		new_shape.position = (points[i] + points[i + 1]) / 2
#		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
#		var length = points[i].distance_to(points[i + 1])
#		rect.extents = Vector2(length / 2, 10)
#		new_shape.shape = rect

	var newShape = CollisionShape2D.new()
	collisions.append(newShape) #Just to keep track of the collisions to later remove them	
	$BodyArea2D.add_child(newShape)
	var rect = RectangleShape2D.new()
	newShape.position = (points[index] + points[index + 1]) / 2
	newShape.rotation = points[index].direction_to(points[index + 1]).angle()
	var length = points[index].distance_to(points[index + 1])
	rect.extents = Vector2(length / 2, self.width / 2)
	newShape.shape = rect
	
	
func clearCollision():
	var latestCollider = null
	if not collisions.empty():
		latestCollider = collisions.front()
	if latestCollider != null:
		for child in $BodyArea2D.get_children():
			if child == latestCollider:
				child.queue_free()
				collisions.erase(collisions.front())

func _on_HeadArea2D_area_entered(area):
	if area.is_in_group("warrior"):
		$CrunchSound.play()
		currentLength += 80
		createDeathParticles(area.position, 1)
		area.queue_free()
		if get_tree().get_nodes_in_group("warrior").size() < 2:
			gameManager.spawnWarriorIfCan()
	elif area.is_in_group("wizard"):
		$CrunchSound.play()
		currentLength += 80
		createDeathParticles(area.position, 2)
		gameManager.availableWizardPositions.append(area.positionSlot)
		area.queue_free()
	elif area.is_in_group("bullet"):
		gameManager.deathMessage("You were hit by a fireball!")
		gameOver()

func _on_BodyArea2D_area_entered(area):
	if area.is_in_group("warrior"):
		if area.swinging == false:
			area.swingSword()
	elif area.is_in_group("bullet"):
		area.queue_free()
		cutSegment(area)

#	# First, find out which point in the line2d is closest to the area to see where to cut it
##	if area.is_in_group("bomb"):
##		var closestPoint
##		var closestPosition = 999999
##		for i in points.size() - 1:
##			if get_point_position(i).distance_to(area.position) < closestPosition:
##				closestPosition = points[i].distance_to(area.position)
##				closestPoint = i
##
##		for i in points.size() - 1:
##			if i <= closestPoint:
##				clearCollision()
##				remove_point(0)
##				currentLength = returnLineLength()

func gameOver():
	set_process(false)
	Global.deathSound.play()
	self.visible = false
	createDeathParticles($HeadArea2D.position, 4)
	gameManager.gameOver()

func _on_HungerTimer_timeout():
	currentLength -= 1
	gameManager.updateStatus($HungerTimer.wait_time * currentLength, currentLength)

func cutSegment(area):
	# First, find out which point in the line2d is closest to the area to see where to cut it	
	var randomSound = get_node("Hurt" + str(randi()%2+1) + "Sound")
	randomSound.play()
	var closestPoint
	var closestPosition = 999999
	for i in points.size() - 1:
		if get_point_position(i).distance_to(area.global_position) < closestPosition:
			closestPosition = points[i].distance_to(area.global_position)
			closestPoint = i
	
	for i in points.size() - 1:
		if i <= closestPoint:
			clearCollision()
			var pointPos = get_point_position(0)
			createDeathParticles(pointPos, 3)
			remove_point(0)
			currentLength = returnLineLength()

func returnHowCloseToHead(area):
	var closestPoint
	var closestPosition = 999999
	for i in points.size() - 1:
		if get_point_position(i).distance_to(area.position) < closestPosition:
			closestPosition = points[i].distance_to(area.position)
			closestPoint = i
	return closestPoint

func _on_BiteArea2D_area_entered(area):
	if area.is_in_group("body"):
		cutSegment($HeadArea2D/Sprite/BiteArea2D)
		gameManager.deathMessage("You bit yourself!")
		gameOver()
	
func createDeathParticles(setPosition, setType):
	var deathParticlesInstance = deathParticles.instance()
	deathParticlesInstance.position = setPosition
	deathParticlesInstance.type = setType
	get_parent().add_child(deathParticlesInstance)
