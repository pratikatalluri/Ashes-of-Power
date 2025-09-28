# EnemySpawner.gd (2D Version)
extends Node2D

# Preload the Enemy scene file. IMPORTANT: This path MUST be correct.
# It assumes Enemy.tscn is in the root 'res://' folder.
var enemy_scene = preload("res://Enemy.tscn") 
var wave = 1
var wave_timer = Timer.new()
# Defines the radius around the center where enemies can spawn (e.g., 500 pixels)
var spawn_radius = 500

func _ready():
	# 1. Add the Timer to the scene tree
	add_child(wave_timer)
	
	# 2. Connect the timer's signal to a function
	wave_timer.connect("timeout", _on_wave_timer_timeout)
	
	# 3. Start the timer for the first wave
	wave_timer.start(5) 
	print("Wave 1 starts in 5 seconds.")

func spawn_wave(number):
	print("Starting Wave %s..." % number)
	var enemy_count = number * 4 # Example: Wave 1 = 4 enemies, Wave 2 = 8, etc.
	
	for i in range(enemy_count):
		# Instantiate the enemy scene created in the previous phase
		var e = enemy_scene.instantiate()
		
		# Calculate a random position in a circle outside of the player's view
		var random_angle = randf() * 360 # Full circle angle
		# Spawn distance is randomly between 200 and 500 pixels from the center
		var spawn_distance = randf_range(200, spawn_radius) 
		
		# Calculate (x, y) coordinates based on polar coordinates
		var pos_x = cos(deg_to_rad(random_angle)) * spawn_distance
		var pos_y = sin(deg_to_rad(random_angle)) * spawn_distance
		
		# Set the enemy's starting position
		e.global_position = Vector2(pos_x, pos_y)
		
		# Add the new enemy instance as a child of the EnemySpawner node
		add_child(e)

func _on_wave_timer_timeout():
	# This function is called when the timer runs out
	wave += 1
	spawn_wave(wave)
	# Restart the timer for the next wave
	wave_timer.start(10)
