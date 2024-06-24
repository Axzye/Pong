class_name Ball
extends ScreenObject

var vel: Vector2

@onready var hit = $Hit
@onready var inside = $Inside


func move(motion: Vector2, delta: float):
	screen_pos += vel * delta
	inside.rotate(vel.y * sign(vel.x) * 0.1 * delta)
	
	# if it WORKS
	var min_y = Game.rect.position.y + size.y * 0.5
	var max_y = Game.rect.end.y - size.y * 0.5
	
	if (screen_pos.y < min_y):
		screen_pos.y = min_y
		vel.y = abs(vel.y)
		hit.play()
	elif (screen_pos.y > max_y):
		screen_pos.y = max_y
		vel.y = -abs(vel.y)
		hit.play()


func bounce_paddle(paddle: Paddle, speed: float):
	# this is so messed up
	if (paddle.player):
		screen_pos.x = Game.rect.position.x + (size.x + paddle.size.x) * 0.5
	else:
		screen_pos.x = Game.rect.end.x - (size.x + paddle.size.x) * 0.5
	
	vel.x = speed
	vel.y += paddle.vel_y * 0.5 + randf_range(-50, 50)
