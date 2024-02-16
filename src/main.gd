extends Node2D

@onready var mouse_positions_queue : Array = Array()
@onready var frame_count : int = 0
@onready var MAX_POINTS : int = 30
@onready var PROCESS_RATE : int = 5
@onready var bezier_curve_enabled : bool = true
@onready var bezier_line_data : Array = Array()
@onready var bezier_angle : Vector2 = Vector2.ZERO

func _ready():
	pass


func _process(_delta) -> void:
	var mouse_pos = get_global_mouse_position()
	# frame count is a helpful variable to make sure it doesn't crash wehn first
	# running due to mouse_positions_queue being empty.
	# TODO: just init the array to Vector2.ZERO
	frame_count += 1
	
	if frame_count % PROCESS_RATE == 0:
		# sussy queue.
		mouse_positions_queue.append(mouse_pos)
		if mouse_positions_queue.size() >= MAX_POINTS:
			# sussy pop()
			mouse_positions_queue.remove_at(0)
	
	var packed_array : PackedVector2Array = PackedVector2Array()
	for i in mouse_positions_queue.size():
		packed_array.append(mouse_positions_queue[i])
	$line_actual.points = packed_array
	
	if frame_count % 1 == 0 and bezier_curve_enabled:
		bezier_line_data = draw_bezier(mouse_positions_queue, 20.0)
		$line_bezier.points = bezier_line_data
	
	$vector.position = mouse_pos
	$"bezier vector".position = mouse_pos
	
	if frame_count > 2 and frame_count % PROCESS_RATE == 0:
		var angle_average : Vector2 = Vector2.ZERO
		var distance_average : float = 0.0
		# added this variable to shorten the lines
		var mpq : Array = mouse_positions_queue
		#for i in  mouse_positions_queue.size() - 2:
		#	angle_average += mpq[mpq.size() - i - 1] - mpq[mpq.size() - i - 2]
		#angle_average /=  mouse_positions_queue.size() - 2
		angle_average = (mpq[mpq.size() - 1] - mpq[mpq.size() - 2]) / 2.0
		
		if bezier_line_data.size() > 10:
			print("calcing avg")
			var s : int = bezier_line_data.size()
			var p1 = bezier_line_data[s - 1]
			var offset = 2
			var p2 = bezier_line_data[s - offset]
			while(p2 == p1 and offset < bezier_line_data.size()):
				offset += 1
				p2 = bezier_line_data[s - offset]
			bezier_angle = p1 - p2
			print(p1)
			print(p2)
		
		# takes the average of distance using 1/10th of the Queue's recorded points.
		for i in (int(mouse_positions_queue.size() / 10)) - 2:
			distance_average += mpq[mpq.size() - i - 1].distance_to(mpq[mpq.size() - i - 2])
		distance_average /=  mouse_positions_queue.size() - 2
		
		$vector.target_position = angle_average.normalized() * 40
		$"bezier vector".target_position = bezier_angle.normalized() * 40
		print(bezier_angle)
	
	$"ui vector".target_position = $vector.target_position
	
	# take pythagorean's of vector components to get 
	# its velocity in units (by default pixels) per frame.
	var current_vel = pow($vector.target_position.x, 2) + pow($vector.target_position.y, 2)
	current_vel = sqrt(current_vel)
	$"ui/bar".value = current_vel
	
	# \u00B0 is the unicode the the degree symbol
	var current_degree = rad_to_deg($vector.target_position.angle())
	$ui/Label.text = str(snapped(current_degree, .1)) + "\u00B0"

func draw_bezier(inp : Array, resolution : float) -> Array:
	# calculate subpoints
	var out : Array = Array()
	var t : float = 0.0
	for i in resolution:
		t += 1.0 / resolution
		for j in inp.size() - 1:
			out.append(de_casteljau(inp, t))
	return out

func de_casteljau(points : Array, t : float) -> Vector2:
	if points.size() == 1:
		return points[0]
	else:
		var new_points = []
		for i in points.size() - 1:
			new_points.append((1 - t) * points[i] + t * points[i + 1])
		return de_casteljau(new_points, t)
