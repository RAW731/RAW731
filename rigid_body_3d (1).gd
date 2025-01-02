extends CharacterBody3D

const SPEED = 5.0
const RUN_SPEED = 20  # سرعة الركض
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 0.10  # جعل سرعة التدوير بطيئة قليلاً
@onready var ap = $AnimationPlayer
@onready var head = $head
@onready var eye = $head/eye
@onready var sprint_timer = $run_time
@onready var sprint_cooldown = $run_rest_timer
@onready var raycast = $head/pistol/RayCast3D
var damege = 12
var idle = true
var attacking = false
var ra = 0
var ra1 = false
var bobbing_normal_speed = 15
var bobbing_normal_ind = 0.3
var bobbing_index = 0.0
var bobbing_vector = Vector2.ZERO
var current_speed: float
var run = false
var walk = true
var dash_speed = 22.0
var dash_duration = 0.2 
var dash_cooldown = 1.0
var dash_timer = 0.0 
var cooldown_timer = 0.0
var is_dashing = false
var dash_direction = Vector3.ZERO
var cooldown_r = false



func _ready():
	# جعل الماوس داخل اللعبة لتتبع الحركة
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func attack():
	if Input.is_action_just_pressed("gun_shoot") and ra1 == false: 
		ap.play("shoot animation")
		attacking = true
		$Timer.start()
		ra += 1
		shoot()

func update_animation(): 
	if not attacking and idle == true: 
		ap.play("idle")
	if ra == 4:
		attacking = false
		idle = false
		ap.play("reload")
		ra = 0
		ra1 = true
		$reload_animation_timer.start()
	attack()
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag: 
		rotate_y(deg_to_rad(-event.relative.x * ROTATION_SPEED)) 
		head.rotate_x(deg_to_rad(-event.relative.y * ROTATION_SPEED))
		
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-45), deg_to_rad(60)) 



func _physics_process(delta: float) -> void:
	# إضافة الجاذبية.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# التعامل مع القفز.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	
	# الحصول على اتجاه الإدخال ومعالجة الحركة/التباطؤ.
	# من الأفضل استبدال الأوامر UI بإجراءات لعب مخصصة.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	bobbing_index += bobbing_normal_speed * delta
	
	if is_on_floor() and input_dir != Vector2.ZERO: 
		bobbing_vector.y = sin(bobbing_index)
		bobbing_vector.x = sin(bobbing_index/2) + 0.5
		
		eye.position.y = lerp(eye.position.y, bobbing_vector.y * (bobbing_normal_ind/2.0), delta)
		eye.position.x = lerp(eye.position.x, bobbing_vector.x * bobbing_normal_ind, delta) 
	
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	current_speed = SPEED
	
	
	
	if Input.is_action_just_pressed("run") and not run and not cooldown_r: 
		run = true
		sprint_timer.start()
		sprint_cooldown.start()
		cooldown_r = true
		
	elif Input.is_action_just_pressed("run") and run: 
		run = false
		cooldown_r = true
		sprint_cooldown.start()
		
	
	if run: 
		current_speed = RUN_SPEED
	
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if Input.is_action_just_pressed ("dash") and not is_dashing and cooldown_timer <=0:
		start_dash()
	
	if is_dashing: 
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		if dash_timer <= 0:
			stop_dash()
	
	update_animation()
	move_and_slide()

func shoot():
	if raycast.is_colliding():
		
		var colpoint = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		var target = raycast.get_collider()
		
		if target != null:
			if target.is_in_group("Enemy") && target.has_method("Enemy_hit"):
				target.Enemy_hit(damege)

func start_dash(): 
	dash_direction = transform.basis.z.normalized()* -1
	is_dashing = true
	dash_timer = dash_duration

func stop_dash(): 
	is_dashing = false
	cooldown_timer = dash_cooldown



func _on_timer_timeout() -> void:
	attacking = false


func _on_reload_animation_timer_timeout() -> void:
	ra1 = false
	idle = true
	attacking = false
	


func _on_run_time_timeout() -> void:
	run = false
	cooldown_r = true
	


func _on_run_rest_timer_timeout() -> void:
	cooldown_r = false
