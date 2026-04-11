class_name LotLayout

## Static layout data for the MVP 3x2 lot grid.
## Positions are Vector2(x, z) in world space. Y (elevation) is always 0.

const LOT_SIZE: float = 16.0

## Returns an Array of Dictionaries: { id, pos, clan }.
static func get_lot_grid() -> Array:
	return [
		{ "id": &"home_base", "pos": Vector2(-20.0, -10.0), "clan": FactionPalette.CHOSEN },
		{ "id": &"lot_2",     "pos": Vector2(  0.0, -10.0), "clan": FactionPalette.CHOSEN },
		{ "id": &"lot_3",     "pos": Vector2(-20.0,  10.0), "clan": FactionPalette.NEUTRAL },
		{ "id": &"lot_4",     "pos": Vector2(  0.0,  10.0), "clan": FactionPalette.NEUTRAL },
		{ "id": &"lot_5",     "pos": Vector2( 20.0, -10.0), "clan": FactionPalette.RIVAL },
		{ "id": &"lot_6",     "pos": Vector2( 20.0,  10.0), "clan": FactionPalette.RIVAL },
	]

## Convert a LotData world_position (Vector2 xz) to a 3D world position.
static func to_world_3d(v2: Vector2) -> Vector3:
	return Vector3(v2.x, 0.0, v2.y)
