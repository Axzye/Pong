class_name Paddle
extends ScreenObject

@export var player: bool

@onready var hit = $Hit

var speed = 350
var accel = 5

var vel_y: float
var score: int


func update():
	position = Vector2(
			0.0 if player else Game.rect.size.x, 
			screen_pos.y - Game.rect.position.y)


func move(input: float, delta: float):
	var actual_accel = accel
	# hear me out: if the signs cancel each other out, they're opposite
	if (sign(input) + sign(vel_y) == 0):
		actual_accel *= 3
	
	# 'tis the pain of framerate independence
	vel_y = lerp(vel_y, speed * input, 1.0 - exp(-actual_accel * delta))
	
	screen_pos.y += vel_y * delta
	
	# if it works...
	var min_y = Game.rect.position.y + size.y * 0.5
	var max_y = Game.rect.end.y - size.y * 0.5
	
	if (screen_pos.y < min_y):
		screen_pos.y = min_y
		if (input == 0):
			vel_y = abs(vel_y)
		else:
			vel_y = 0
	elif (screen_pos.y > max_y):
		screen_pos.y = max_y
		if (input == 0):
			vel_y = -abs(vel_y)
		else:
			vel_y = 0
	
	update()
