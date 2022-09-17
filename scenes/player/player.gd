# Strafing mechanics for Godot 4.0
# Copyright (c) 2022 ic3bug
# MIT License
class_name Player
extends CharacterBody3D

# Gravity
const GRAVITY : float = 32.0
# Maximum speed
const MAX_SPEED : float = 20.0
# Tweak the maximum acceleration to your liking
const MAX_ACCEL : float = 150.0
# Jump force
const JUMP_FORCE : float = 12.0
# Ground friction
const FRICTION : float = 0.86
# Increase air drag by tiny amounts to make strafing faster
const AIR_DRAG : float = 0.98

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jumping
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_FORCE
		$Sound.play()

	# Input direction
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Movement direction
	var dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()

	# Friction and air drag for horizontal velocity
	var hvel = velocity
	hvel.y = 0.0
	var decel = FRICTION if is_on_floor() else AIR_DRAG
	hvel *= decel
	
	# Zero out horizontal velocity if speed is too small
	if hvel.length() < MAX_SPEED * 0.01:
		hvel = Vector3.ZERO
	
	# Acceleration
	# Here lies the strafing mechanic (bug)
	# Projection of the horizontal velocity to the direction
	var speed = hvel.dot(dir)
	# Whenever the amount of acceleration to add is clamped by the maximum acceleration constant
	# Player can make the speed faster by bringing the direction closer to horizontal velocity angle
	# More info here: https://youtu.be/v3zT3Z5apaM?t=165
	var accel : float = clamp(MAX_SPEED - speed, 0.0, MAX_ACCEL * delta)
	hvel += dir * accel
	
	# Apply horizontal velocity to final velocity
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	# Godot's move and slide function
	move_and_slide()
