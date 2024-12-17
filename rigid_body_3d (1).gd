extends CharacterBody3D

const SPEED = 5.0
const RUN_SPEED = 10.0  # سرعة الركض
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 0.10  # جعل سرعة التدوير بطيئة قليلاً
@onready var ap = $AnimationPlayer
@onready var head = $head
var idle = true
var attacking = false
var ra = 0
var ra1 = false

func _ready():
	# جعل الماوس داخل اللعبة لتتبع الحركة
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func attack():
	if Input.is_action_just_pressed("gun_shoot") and ra1 == false: 
		ap.play("shoot animation")
		attacking = true
		$Timer.start()
		ra += 1
		

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
func _input(event): 
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

	# التحقق إذا كان اللاعب يركض (إذا كان يضغط على زر الركض)
	var is_running = Input.is_action_pressed("shift")  # يمكن تغيير "ui_shift" إلى أي زر تريده
	
	# تحديد السرعة بناءً على حالة الركض
	var current_speed: float
	if is_running:
		current_speed = RUN_SPEED
	else:
		current_speed = SPEED

	# الحصول على اتجاه الإدخال ومعالجة الحركة/التباطؤ.
	# من الأفضل استبدال الأوامر UI بإجراءات لعب مخصصة.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# حساب التغيير في إحداثيات الماوس
	

	# تدوير الشخصية بناءً على حركة الماوس
	

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	update_animation()
	
	
	move_and_slide()


func _on_timer_timeout() -> void:
	attacking = false


func _on_reload_animation_timer_timeout() -> void:
	ra1 = false
	idle = true
	attacking = false
