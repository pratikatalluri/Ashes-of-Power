# Player.gd (2D Version)
extends CharacterBody2D

# Core Stat
var health = 100.0
var max_health = 100.0
var speed = 300.0 # Faster speed needed for 2D
var ash = 50.0 # Start with some Ash for testing
var invulnerable = false
var is_vowing = false # Flag to hold the V key state

# Ritual Costs
const RITUAL_COSTS = {"ritual1": 50, "ritual2": 75, "ritual3": 100}

# References to the main game nodes
var enemy_spawner

func _ready():
	# Find the Enemy Spawner node (make sure you create the EnemySpawner!)
	enemy_spawner = get_parent().get_node("EnemySpawner")
	
	print("Health: %s, Speed: %s, Ash: %s" % [health, speed, ash])

func _physics_process(delta):
	# --- MOVEMENT ---
	var dir = Vector2.ZERO
	# W/S move along the Y-axis (Up/Down)
	if Input.is_action_pressed("move_down"): dir.y += 1
	if Input.is_action_pressed("move_up"): dir.y -= 1
	# A/D move along the X-axis (Left/Right)
	if Input.is_action_pressed("move_left"): dir.x -= 1
	if Input.is_action_pressed("move_right"): dir.x += 1
	
	# Apply speed and move the body
	velocity = dir.normalized() * speed
	move_and_slide()
	
	# --- RITUAL INPUT ---
	if Input.is_action_just_pressed("vow"):
		is_vowing = true
		print("VOW initiated. Press 1, 2, or 3 to choose a Ritual.")
	
	if is_vowing:
		if Input.is_action_just_pressed("ritual1"):
			perform_ritual(1, "Pyre of Redemption", "Health Vow")
		elif Input.is_action_just_pressed("ritual2"):
			perform_ritual(2, "Vessel of Embers", "Speed Vow")
		elif Input.is_action_just_pressed("ritual3"):
			perform_ritual(3, "Stasis of Loss", "Speed Vow")
			
	if Input.is_action_just_released("vow"):
		is_vowing = false

# Main Ritual Function
func perform_ritual(id, ritual_name, vow_name):
	var cost = RITUAL_COSTS["ritual" + str(id)]
	
	if ash < cost:
		print("Not enough Ash for %s. Cost: %s, Current: %s" % [ritual_name, cost, ash])
		is_vowing = false
		return
		
	ash -= cost
	
	# --- APPLY SACRIFICE (PERMANENT DEBUFF) ---
	if vow_name == "Health Vow":
		max_health *= 0.85  # -15% Max Health
		health = min(health, max_health) # Shrink current health if it exceeds new max
		print("SACRIFICE: %s! Max Health is now %s" % [vow_name, max_health])
	elif vow_name == "Speed Vow":
		speed *= 0.9  # -10% Movement Speed
		print("SACRIFICE: %s! Speed is now %s" % [vow_name, speed])
		
	# --- PERFORM RITUAL EFFECT ---
	match id:
		1: # Pyre of Redemption (Blast)
			print("%s executed! Huge AoE damage (placeholder)." % ritual_name)
			# Placeholder: Delete all enemies near the player (radius 300)
			for enemy in enemy_spawner.get_children():
				if enemy.global_position.distance_to(global_position) < 300:
					enemy.queue_free()
		2: # Vessel of Embers (Shield)
			print("%s executed! Invulnerable for 5 seconds." % ritual_name)
			invulnerable = true
			$InvulTimer.start(5)
		3: # Stasis of Loss (Freeze)
			print("%s executed! Freezing enemies for 8 seconds." % ritual_name)
			for enemy in enemy_spawner.get_children():
				if enemy.has_method("freeze"):
					enemy.freeze(8)
					
	is_vowing = false
	print("Health: %s, Speed: %s, Ash: %s" % [health, speed, ash])

# Signal connected to the $InvulTimer's 'timeout'
func _on_invul_timer_timeout():
	invulnerable = false
	print("Invulnerability ended.")
	
# Function for enemies to call when they hit the player
func take_damage(amount):
	if invulnerable:
		return
	health -= amount
	print("Player hit! Health remaining: %s" % health)
	if health <= 0:
		print("GAME OVER")
		get_tree().quit() # Simple exit for hackathon
