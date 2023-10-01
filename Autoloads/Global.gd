extends Node

onready var buttonSelect = $ButtonSelect
onready var buttonHover = $ButtonHover
onready var deathSound = $DeathSound

onready var crosshair = preload("res://Assets/crosshair.png")

var savePath = "user://saveSnakeDungeonLeaderboardScore.dat"
var playerData = null # to be saved content

var leaderBoard = []
var playerName = "N/A"
var playerID = "0"
var quitToLeaderboard = false

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(0.05))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear2db(0.15))
	Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, Vector2(4,4))


func saveData(highScore):
	var data = {
		"HighScore" : highScore
	}
	var file = File.new()
	var error = file.open(savePath, File.WRITE)
	if error == OK:
		file.store_var(data)
		file.close()
	Lootlocker._upload_score(highScore)
	Lootlocker._change_player_name_ingame(playerName) # experimental
#	Lootlocker._get_leaderboards()

func loadData():
	var file = File.new()
	if file.file_exists(savePath):
		var error = file.open(savePath, File.READ)
		if error == OK:
			playerData = file.get_var()
			file.close()
			print(playerData)

