extends Control

onready var bgSoundSlider = $Settings/VBoxContainer/MusicVolumeSlider
onready var effectSoundSlider = $Settings/VBoxContainer/EffectVolumeSlider

onready var playerScore = preload("res://GameObjects/PlayerScore.tscn")

func _ready():
	Lootlocker.loadingScreen.visible = false
	Lootlocker.enterPlayerName.visible = false
	Global.loadData()
	$PlayerNameLabel.text = Global.playerName + " (" + Global.playerID + ")"
	
	
	if Global.playerData != null:
		$MainScreen/HighscoreLabel.text = "Highscore: " + str(Global.playerData["HighScore"])
	
	bgSoundSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	effectSoundSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))
#	if not Global.leaderBoard.empty():
#		organizeLeaderboard()
	
	if Global.quitToLeaderboard == true:
		Global.quitToLeaderboard = false
		$MainScreen.visible = false
		$Leaderboard.visible = true
	
	organizeLeaderboard()
	

func _on_PlayButton_pressed():
	Global.buttonSelect.play()
	get_tree().change_scene("res://Levels/GameManager.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Button_mouse_entered():
	Global.buttonHover.play()

func _on_BackButton_pressed():
	Global.buttonSelect.play()	
	$Settings.visible = false
	$Leaderboard.visible = false
	$MainScreen.visible = true

func _on_SettingsButton_pressed():
	Global.buttonSelect.play()	
	$Settings.visible = true
	$MainScreen.visible = false


func _on_MusicVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))


func _on_EffectVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear2db(value))

func _on_LeaderboardButton_pressed():
	Global.buttonSelect.play()
	$Leaderboard.visible = true
	$MainScreen.visible = false

func organizeLeaderboard():
	$Leaderboard/LoadingLabel.visible = false
	var counter = 0
	for child in $Leaderboard/Leaderboard.get_children():
		child.queue_free()
	for rank in Global.leaderBoard:
		counter += 1
		if counter < 10:
			var playerScoreInstance = playerScore.instance()
			playerScoreInstance.text = rank
			$Leaderboard/Leaderboard.add_child(playerScoreInstance)


func _on_CheckLeaderboardTimer_timeout():
	organizeLeaderboard()

