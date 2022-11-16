extends Node

export var rooms = 10
export var map_height = 20
export var map_width  = 35
export var min_height = 2
export var min_width  = 2

func _new_node(x, y, height, width):
	var n = {
		left = null,
		right = null,
		height = height,
		width = width,
		x = x,
		y = y,
		room = null
	}
	return n

func _new_room(node):
	var height = int(rand_range(min_height, node.height))
	var width = int(rand_range(min_width, node.width))
	return {
		height = height,
		width = width, 
		x = node.x + int(rand_range(0, node.width - width)),
		y = node.y + int(rand_range(0, node.height - height))
	}

func _split(node):
	if (node.height < 1 + min_height * 2 and
		node.width < 1 + min_width * 2):
			node.room = _new_room(node)
			return
	if node.height * rand_range(0.8, 1.2) > node.width:
		var h = max(min_height, int(node.height * rand_range(0.4, 0.6)))
		var w = node.width
		node.left = _new_node(node.x, node.y,
			h, w)
		node.right = _new_node(node.x, node.y + h,
			node.height - h, node.width)
	else:
		var h = node.height
		var w = max(min_width, int(node.width * rand_range(0.4, 0.6)))
		node.left = _new_node(node.x, node.y,
			h, w)
		node.right = _new_node(node.x + w, node.y,
			node.height, node.width - w)

	_split(node.left)
	_split(node.right)

func _gen_hall(room_l, room_r):
	var hall = []
	var width = int(rand_range(1, 3))

	var x1 = int(room_l.x) + int(rand_range(0, room_l.width))
	var y1 = int(room_l.y) + int(rand_range(0, room_l.height))
	var x2 = int(room_r.x) + int(rand_range(0, room_r.width))
	var y2 = int(room_r.y) + int(rand_range(0, room_r.height))
	
	
	if (x1 < x2):
		if (y1 < y2):
			hall.append({ x = x1, y = y1, width = abs(x1 - x2), height = width })
			hall.append({ x = x2, y = y1, width = width, height = abs(y1 - y2) })
		else:
			hall.append({ x = x1, y = y2, width = abs(x1 - x2), height = width })
			hall.append({ x = x1, y = y2, width = width, height = abs(y1 - y2) })
	else:
		if (y1 < y2):
			hall.append({ x = x2, y = y1, width = abs(x1 - x2), height = width })
			hall.append({ x = x2, y = y1, width = width, height = abs(y1 - y2) })
		else:
			hall.append({ x = x2, y = y2, width = abs(x1 - x2), height = width })
			hall.append({ x = x1, y = y2, width = width, height = abs(y1 - y2) })

	return hall

func _new_map():
	var map = []
	for i in range(0, map_height + 2):
		var line = ""
		for j in range(0, map_width + 2):
			line += "#"
		map.append(line)
	return map

func _halls(node, halls):
#	print(node.left ==  null)
#	print(node.right ==  null)
#	print(node.left.room ==  null)
#	print(node.right.room ==  null)
#	print("zalupa")

	if (not node.left.room):
		var new_segment = _halls(node.left, halls)
		node.left.room = new_segment
	if (not node.right.room):
		var new_segment = _halls(node.right, halls)
		node.right.room = new_segment

	var hall = _gen_hall(node.left.room, node.right.room)
	halls.append(hall[0])
	halls.append(hall[1])
	return hall[0]

func _extract_rooms(node, rooms):
	if (not node.left and not node.right):
		rooms.append(node.room)
		return
	_extract_rooms(node.left, rooms)
	_extract_rooms(node.right, rooms)

func _draw_rooms(map, node):
	var rooms = []
	_extract_rooms(node, rooms)

	for room in rooms:
		for i in range(room.x, room.x + room.width):
			for j in range(room.y, room.y + room.height):
				map[j+1][i+1] = "."

func _draw_halls(map, halls):
	for room in halls:
		for i in range(room.x, room.x + room.width):
			for j in range(room.y, room.y + room.height):
				map[j+1][i+1] = "."

func gen():
	var node: Dictionary = {
		left = null,
		right = null,
		height = map_height,
		width = map_width,
		x = 0,
		y = 0,
		room = null
	}

	_split(node)
	var halls = []
	_halls(node, halls)
	var map = _new_map()
	_draw_rooms(map, node)
	_draw_halls(map, halls)

	return map


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var map = gen()
	for line in map:
		print(line)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
