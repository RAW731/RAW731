extends Control

# قم بتحديد الصورة الخاصة بالكروس هير هنا
@export var crosshair_texture : Texture

func _ready():
	var texture_rect = TextureRect.new()
	texture_rect.texture = crosshair_texture
	texture_rect.rect_min_size = Vector2(32, 32)  # حجم الكروس هير
	
	# تعيين المحاذاة إلى المنتصف
	texture_rect.alignment = TextureRect.ALIGN_CENTER  # المحاذاة في المنتصف
	
	add_child(texture_rect)

	# ضع الكروس هير في وسط الشاشة
	texture_rect.rect_position = (get_viewport().size / 2) - texture_rect.rect_min_size / 2
