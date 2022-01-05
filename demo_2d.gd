# Script to attach to a node which represents a hex grid
extends Node2D

var HexGrid = preload("./HexGrid.gd").new()

onready var tile = $tile
onready var highlight = get_node("Highlight")
onready var area_coords = get_node("Highlight/AreaCoords")
onready var hex_coords = get_node("Highlight/HexCoords")

var hex_scale = 50
var tiles = {}

func _ready():
    var hex_scale_v = Vector2(hex_scale, hex_scale)
    HexGrid.hex_scale = hex_scale_v
    HexGrid.set_bounds(-hex_scale_v, hex_scale_v)
    
    for x in range(-20, 20):
        for y in range(-20, 20):
            var pos = Vector2(x, y) * hex_scale / 2
            var hex = HexGrid.get_hex_at(pos)
            var hl = tile.duplicate()
            tiles[hex.axial_coords] = hl
            add_child(hl)
            hl.modulate = Color.gray
            hl.position = HexGrid.get_hex_center(hex)

    highlight.z_index = 4

    find_path()

func _unhandled_input(event):
    if 'position' in event:
        var relative_pos = self.transform.affine_inverse() * event.position
        var hex = HexGrid.get_hex_at(relative_pos)
        # Display the coords used
        if area_coords != null:
            area_coords.text = str(relative_pos)
        if hex_coords != null:
            hex_coords.text = str(hex.axial_coords)
        
        # Snap the highlight to the nearest grid cell
        if highlight != null:
            highlight.position = HexGrid.get_hex_center(hex)

        if event is InputEventMouseButton and event.pressed:
            if event.button_index == 2:
                HexGrid.remove_obstacles(hex)
            else:
                HexGrid.add_obstacles(hex)
            find_path()

func refresh_tiles():
    for tile in tiles.values():
        tile.modulate = Color.gray
    
    for obstacle in HexGrid.get_obstacles():
        if tiles.has(obstacle):
            tiles[obstacle].modulate = Color.darkgray


func find_path():
    refresh_tiles()

    var line_start = Vector2(-2, -2) * hex_scale / 2
    var line_end = Vector2(3, 5) * hex_scale / 2

    var start = HexGrid.get_hex_at(line_start)
    print("start: %s" % start.axial_coords)
    var start_hilight = tiles[start.axial_coords]
    start_hilight.modulate = Color.red
    start_hilight.z_index = 3

    var end = HexGrid.get_hex_at(line_end)
    print("end: %s" % end.axial_coords)
    var end_hilight = tiles[end.axial_coords]
    end_hilight.modulate = Color.yellow
    end_hilight.z_index = 3

    var line = HexGrid.find_path(start, end)
    for i in range(1, line.size() - 1):
        var l = line[i]
        tiles[l.axial_coords].modulate = Color.lightgreen
        tiles[l.axial_coords].z_index = 2
