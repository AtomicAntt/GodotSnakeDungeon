extends Node2D

onready var highLabel = $GameUI/GameStatus/High
onready var currentLabel = $GameUI/GameStatus/Current
onready var lifeExpectancyLabel = $GameUI/GameStatus/LifeExpectancy

onready var gameOverUI = $GameUI/GameOver

onready var wizardPositions = $WizardPositions
onready var warriorPositions = $WarriorPositions

onready var wizard = preload("res://GameObjects/Wizard.tscn")
onready var warrior = preload("res://GameObjects/Warrior.tscn")

var playerDead = false

var greatestLength = 0

var availableWizardPositions = []
var points = 0

func _ready():
	Global.loadData()
	get_tree().paused = false
	
	spawnWarriorIfCan()
	spawnWarriorIfCan()
	
	for child in wizardPositions.get_children():
		availableWizardPositions.append(child)

func updateStatus(time, currentLength):
	if time > 0 and currentLength > 0:
		lifeExpectancyLabel.text = str(stepify(time, 0.01))
		currentLabel.text = "Current: " + str('%05d' % currentLength)
		if currentLength > greatestLength:
			highLabel.text = "High: " + str('%05d' % currentLength)
			points = floor(currentLength)
			greatestLength = currentLength

func gameOver():
	$Music.stop()
	playerDead = true
	gameOverUI.visible = true
	$GameUI/GameOver/AnimationPlayer.play("appear")
	$GameUI/GameOver/VBoxContainer/ScoreLabel.text = "Score: " + str(points)
	# replace high score cuz none first place
	if Global.playerData == null:
		$GameUI/GameOver/NewHighscore.visible = true
		$GameUI/GameOver/NewHighscore/VBoxContainer/PrevHighscore.text = "Prev: N/A"
		Global.saveData(points)
	else:
		# Higher than last high score, replace
		if Global.playerData["HighScore"] < points:
			$GameUI/GameOver/NewHighscore.visible = true
			$GameUI/GameOver/NewHighscore/VBoxContainer/PrevHighscore.text = "Prev: " + str(Global.playerData["HighScore"])
			Global.saveData(points)
		else:
			$GameUI/GameOver/NewHighscore.visible = false
			
	
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = true

func _on_RestartButton_pressed():
	get_tree().paused = false
	Global.buttonSelect.play()
	get_tree().reload_current_scene()
	
func _on_QuitToMenuButton_pressed():
	Global.buttonSelect.play()
	get_tree().change_scene("res://Levels/Main Menu.tscn")


func _on_SpawnWizardTimer_timeout():
#	pass
	spawnWizardIfCan()

func spawnWizardIfCan():
	if not availableWizardPositions.empty():
		var randomPos = availableWizardPositions[randi() & availableWizardPositions.size() - 1]
		availableWizardPositions.erase(randomPos)
		var wizardInstance = wizard.instance()
		wizardInstance.positionSlot = randomPos
		wizardInstance.position = randomPos.position
		add_child(wizardInstance)

func spawnWarriorIfCan():
	if get_tree().get_nodes_in_group("warrior").size() < 15:	
		var randomPosArray = warriorPositions.get_children()
		var randomPos = randomPosArray[randi() & randomPosArray.size() - 1]
		var warriorInstance = warrior.instance()
		warriorInstance.position = randomPos.position
		add_child(warriorInstance)

func _on_SpawnWarriorTimer_timeout():
	spawnWarriorIfCan()

func deathMessage(message):
	$GameUI/GameOver/DeathMessage.text = message


func _on_Button_mouse_entered():
	Global.buttonHover.play()

func _on_Leaderboard_pressed():
	Global.buttonSelect.play()
	get_tree().change_scene("res://Levels/Main Menu.tscn")
	Global.quitToLeaderboard = true
	
