extends Spatial

export (Dictionary) var tilemap
export (PackedScene) var player
export (Array) var enemiesPool
export (PackedScene) var light
export (PackedScene) var shrine

var playerInstance: KinematicBody
var player_start_x
var player_start_y

var door

var map = []
var prev_pos = null
#var map = [
#	"####################################",
#	"#...............................S..#",
#	"#.....P....#######.................#",
#	"#..........#.....#.................#",
#	"#S.........#S....#########..########",
#	"#..........#.............#..########",
#	"#..........#....##########..########",
#	"#..........#....#..................#",
#	"#..........#....#.......E..........#",
#	"#..........#....#..................#",
#	"#..........#....#..................#",
#	"#...............#............S.....#",
#	"####################################"
#]

var lightmap = []

var minimap = null

func draw_minimap():
	var m_txt = ""
	for i in range(1, len(minimap) + 1):
		var line = minimap[len(minimap) - i]
		m_txt += line + "\n"
	playerInstance.get_node("UserInterface/HUD/Map").text = m_txt

func _gen_exit():
	var first_coord_line = int(rand_range(0, len(map)))
	var first_coord_ch =   int(rand_range(0, len(map[0])))

	var i = first_coord_line
	var j = first_coord_ch
	
	while true:
		while true:
			var start_x = clamp(i - 1, 0, len(map))
			var start_y = clamp(j - 1, 0, len(map[0]))
			var end_x = clamp(i + 1, 0, len(map))
			var end_y = clamp(j + 1, 0, len(map[0]))
		
			if map[i][j] == "#":
				var near_cells = 0
				if i - 1 > 0 and map[i - 1][j] == '.':
					near_cells += 1
				if i + 1 < len(map) and map[i + 1][j] == '.':
					near_cells += 1
				if j - 1 > 0 and map[i][j - 1] == '.':
					near_cells += 1
				if j + 1 < len(map[0]) and map[i][j + 1] == '.':
					near_cells += 1
				if near_cells > 0:
					map[i][j] = "D"
					return

			j = (j + 1) % len(map[0])
			if j == first_coord_ch:
				break;
		i = (i + 1) % len(map)
		if i == first_coord_line:
			map[i][j] = "D"
			return


# Called when the node enters the scene tree for the first time.
func _ready():
	playerInstance = player.instance()
	var sp = false
	randomize()
	map = $bspgen.gen()
	_gen_exit()
	var i = 0
	var j = 0
	for line in map:
		for ch in line:
			if (ch == "."):
				if rand_range(0, 1) < 0.03:
					ch = "E"
				elif rand_range(0, 1) < 0.03:
					ch = "S"
				if not sp:
					sp = true
					ch = "P"
			if (ch == "S"):
				print(ch)
				var p: Spatial = shrine.instance()
				p.translation = Vector3(i*2, 1.5, j*2)
				p.get_node("trigger_area").connect("player_entered", playerInstance, "_on_shrine_player_entered")
				p.get_node("trigger_area").connect("player_exited", playerInstance, "_on_shrine_player_exited")
				add_child(p)
				ch = "."
			if (ch == "P"):
				print(ch)
				playerInstance.translation = Vector3(i*2, 0.5, j*2)
				add_child(playerInstance)
				ch = "."
			if (ch == "E"):
				var p: KinematicBody = enemiesPool[rand_range(0, len(enemiesPool))].instance()
				p.translation = Vector3(i*2, 0.5, j*2)
				p.player = playerInstance
				p.map = map
				add_child(p)
				ch = "."
			var tile: Node = tilemap[ch][rand_range(0, len(tilemap[ch]))].instance()
			if (ch == "D"):
				door = tile
				tile.connect("player_entered", playerInstance, "_on_door_player_entered")
			tile.translation = Vector3(i*2, 0, j*2)
#			tile.x = i
#			tile.z = j
			j += 1
			add_child(tile)
		i += 1
		j = 0

	minimap = map
	lightmap = map
	
	i = 0
	j = 0
	for line in lightmap:
		for ch in line:
			if ch == ".":
				if rand_range(0, 1) < 0.05:
					ch = "L"
			if ch == "L":
				var l: Spatial = light.instance()
				l.translation = Vector3(i*2, 0.25, j*2)
				add_child(l)
			j += 1
		i += 1
		j = 0

func _process(delta):
	if playerInstance.killed >= 5 and door:
		door.get_node("Stop/CollisionShape").set_disabled(true)
		door.get_node("MeshInstance").visible = false
		door.get_node("MeshInstance2").visible = true

func _physics_process(delta):
	if minimap:
		var player_origin = playerInstance.global_transform.origin
		var player_pos = Vector2(floor((player_origin.x + 0.5) / 2), ceil((player_origin.z - 0.5) / 2))
	
		if prev_pos:
			var p = prev_pos.vec
			minimap[p.x][p.y] = prev_pos.ch
	
		prev_pos = {
			vec = player_pos
		}
		prev_pos.ch = minimap[player_pos.x][player_pos.y]
		minimap[player_pos.x][player_pos.y] = "@"
		
		draw_minimap()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
