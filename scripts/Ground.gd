extends StaticBody2D

onready var _collisionPoly = get_node("CollisionPolygon2D")
onready var _mesh = get_node("MeshInstance2D")
onready var _lightOccluder = get_node("LightOccluder2D")

func _ready():
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	var vert_array = _collisionPoly.polygon
	arrays[ArrayMesh.ARRAY_VERTEX] = vert_array
	arrays[ArrayMesh.ARRAY_INDEX] = Geometry.triangulate_polygon(vert_array)	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh.mesh = arr_mesh
	
	_mesh.modulate = Color("b3a6a3")
	var duplicated = _mesh.duplicate()
	duplicated.position.x += 1.0
	add_child(duplicated)
	duplicated = _mesh.duplicate()
	duplicated.position.x -= 1.0
	add_child(duplicated)
	duplicated = _mesh.duplicate()
	duplicated.position.y += 1.0
	add_child(duplicated)
	duplicated = _mesh.duplicate()
	duplicated.position.y -= 1.0
	add_child(duplicated)
	
	_mesh.modulate = Color.black
	remove_child(_mesh)
	add_child(_mesh)
	
	var occluder = OccluderPolygon2D.new()
	occluder.set_polygon(vert_array)
	_lightOccluder.occluder = occluder
