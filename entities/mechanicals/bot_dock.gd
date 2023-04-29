extends Node3D

@export var desired_bot_path: NodePath
var desired_bot: Node3D
var is_bot_on_dock: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	desired_bot = get_node(desired_bot_path)
	$BotDetection.body_entered.connect(on_bot_detection_entered)
	$BotDetection.body_exited.connect(on_bot_detection_left)

func on_bot_detection_entered(body: Node3D):
	if body == desired_bot:
		is_bot_on_dock = true
		print("Desired bot ", desired_bot.name)
	else:
		print("Undesired: ", body.name)

func on_bot_detection_left(_body: Node3D):
	var existing_bodies: Array = $BotDetection.get_overlapping_bodies()
	if existing_bodies.has(desired_bot):
		is_bot_on_dock = true
	else:
		is_bot_on_dock = false
		
