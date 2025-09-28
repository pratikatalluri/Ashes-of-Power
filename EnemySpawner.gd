# EnemySpawner.gd
extends Node2D

# --- CONFIGURATION ---
@export var enemy_scene: PackedScene # ASSIGN IN INSPECTOR
@export var player_node: CharacterBody2D # ASSIGN IN INSPECTOR
@export var spawn_radius = 500.0 

# Wave Control
var current_wave = 0
var max_waves = 5 
var enemies_per_wave = 0 # Starts at 0, first wave sets it to 5
var enemies_spawned_this_wave = 0
var enemies_alive = 0
var is_boss_wave = false

# Timer Reference (Requires a Timer node named "WaveTimer" as a child)
@onready var wave_timer: Timer = $WaveTimer

# --- SETUP ---

func _ready():
	# 1. Timer setup checks
	if not wave_timer:
		print("ERROR: WaveTimer node not found! Check if it's a child and named 'WaveTimer'.")
		return
		
	wave_timer.autostart = false
	wave_timer.one_shot = true 
	enemies_per_wave = 5 # Initial difficulty
	start_next_wave()

# --- WAVE MANAGEMENT ---

func start_next_wave():
	current_wave += 1
	enemies_spawned_this_wave = 0
	enemies_alive = 0
	
	if current_wave > max_waves:
		start_boss_wave()
	else:
		print("Starting Wave %d / %d with %d enemies" % [current_wave, max_waves, enemies_per_wave])
		
		wave_timer.wait_time = 1.0 # 1 second delay between spawns
		wave_timer.start()

func start_boss_wave():
	is_boss_wave = true
	print("BOSS WAVE STARTED!")
	
	enemies_per_wave = 1
	enemies_alive = 1
	spawn_enemy(true) # Spawn a tougher boss enemy

func spawn_enemy(is_boss = false):
	# Spawns enemy outside the spawn_radius circle around the player
	var angle = randf_range(0, TAU)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_position = player_node.global_position + spawn_offset
	
	var new_enemy = enemy_scene.instantiate()
	get_parent().add_child(new_enemy) # Spawns enemy as sibling to Player/Spawner
	new_enemy.global_position = spawn_position
	
	if is_boss:
		new_enemy.speed *= 2.5
		new_enemy.ash_value = 100 
		
	enemies_spawned_this_wave += 1
	enemies_alive += 1

# --- SIGNAL CALLBACKS ---

# Must be connected to WaveTimer's 'timeout()' signal in the Editor
func _on_wave_timer_timeout():
	if enemies_spawned_this_wave < enemies_per_wave:
		spawn_enemy()
		wave_timer.start() # Restart the timer for the next enemy
	else:
		print("Wave %d spawning complete. Waiting for enemies to die..." % current_wave)

# Called by Enemy.gd's die() function
func enemy_died():
	enemies_alive -= 1
	
	if enemies_alive <= 0:
		if is_boss_wave:
			print("GAME WON!")
		else:
			print("Wave %d cleared!" % current_wave)
			enemies_per_wave += 2 # Increase difficulty
			await get_tree().create_timer(3.0).timeout # 3 second break
			start_next_wave()its no
