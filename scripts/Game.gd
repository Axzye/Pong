class_name Game
extends Node

enum { START, READY, PLAY }

@onready var window = get_window()

@onready var back_1 = $Back1
@onready var back_2 = $Back2
@onready var p1 = $P1
@onready var p2 = $P2
@onready var ball = $Ball
@onready var start_timer = $StartTimer
@onready var score = $Score

static var rect: Rect2

signal update_pos

var game_state := START
var ball_speed: float


func _ready():
	window.always_on_top = true
	window.min_size = Vector2(100.0, 100.0)
	start_timer.timeout.connect(start_round)
	
	rect = Rect2(window.position, window.size)
	reset_positions()
	
	if (window.size != Vector2i(600, 400)):
		push_warning("Unexpected init window size " + str(window.size))
	
	DisplayServer.window_set_title("Press SPACE to start")


func _process(delta):
	var old_rect = rect
	rect = Rect2(window.position, window.size)
	print(rect)
	
	var motion := Vector2(rect.position - old_rect.position)
	
	update_pos.emit()
	
	if (game_state == START):
		reset_positions()
		if (Input.is_action_pressed("Start")):
			start_timer.start()
			game_state = READY
			DisplayServer.window_set_title("Ready...")
		return
	
	if (game_state == READY):
		reset_positions()
		return
	
	var p1_input = Input.get_axis("Up", "Down")
	var p2_input
	
	var prediction = ball.screen_pos.y - p2.screen_pos.y
	prediction += (ball.vel.x * ball.vel.y * delta * delta)
	
	if (abs(prediction) < 10.0):
		prediction = 0
	
	p2_input = sign(prediction)
	
	p1.move(p1_input, delta)
	p2.move(p2_input, delta)
	
	ball.move(motion, delta)
	
	# dumpster fire
	var hit_x = (rect.size.x - p1.size.x - ball.size.x) * 0.5
	
	if (ball.screen_pos.x <= rect.get_center().x - hit_x):
		check_side(p1)
	elif (ball.screen_pos.x >= rect.get_center().x + hit_x):
		check_side(p2)


func start_round():
	ball_speed = 250
	
	ball.vel = Vector2(ball_speed, randf_range(-100.0, 100.0))
	
	game_state = PLAY
	DisplayServer.window_set_title("Go!")


func end_round():
	start_timer.start()
	game_state = READY


func reset_positions():
	p1.screen_pos = rect.get_center()
	p2.screen_pos = rect.get_center()
	ball.screen_pos = rect.get_center()
	update_pos.emit()


func check_side(side: Paddle):
	var hit_width = (side.size.y + ball.size.y) * 0.5
	
	if (abs(ball.screen_pos.y - side.screen_pos.y) < hit_width):
		ball_speed += 10
		ball.bounce_paddle(side, ball_speed if side.player else -ball_speed)
		
		side.hit.play()
		# Return early to prevent scoring at the same time
		return
	
	var score_x = (rect.size.x + ball.size.x) * 0.5
	
	if (ball.screen_pos.x < rect.get_center().x - score_x or 
		ball.screen_pos.x > rect.get_center().x + score_x):
		side.score += 1
		score.play()
		DisplayServer.window_set_title(("P2" if side.player else "P1") + " scored!")
		end_round()
