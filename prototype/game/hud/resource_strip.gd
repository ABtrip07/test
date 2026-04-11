extends Control

## Resource readout strip. Listens to Resources.resource_changed and updates labels.

const _RES_ORDER: Array[int] = [
	ResourceTypes.ResourceType.FOOD,
	ResourceTypes.ResourceType.SCRAP,
	ResourceTypes.ResourceType.FUEL,
	ResourceTypes.ResourceType.PEOPLE,
]

const _ICONS: Dictionary = {
	ResourceTypes.ResourceType.FOOD: "Food",
	ResourceTypes.ResourceType.SCRAP: "Scrap",
	ResourceTypes.ResourceType.FUEL: "Fuel",
	ResourceTypes.ResourceType.PEOPLE: "People",
}

var _labels: Dictionary = {}  # type -> Label
var _panel: PanelContainer

func initialize() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.10, 0.08, 0.78)
	sb.border_color = Color(0.6, 0.45, 0.2, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	_panel.add_child(row)

	for t: int in _RES_ORDER:
		var cell: HBoxContainer = HBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var icon_lbl: Label = Label.new()
		icon_lbl.text = _ICONS[t] + ":"
		icon_lbl.add_theme_color_override("font_color", Color(0.85, 0.80, 0.6))
		icon_lbl.add_theme_font_size_override("font_size", 14)
		cell.add_child(icon_lbl)
		var val: Label = Label.new()
		val.text = "0"
		val.add_theme_color_override("font_color", Color(1, 1, 1))
		val.add_theme_font_size_override("font_size", 16)
		cell.add_child(val)
		_labels[t] = val
		row.add_child(cell)

	Resources.resource_changed.connect(_on_resource_changed)
	_refresh_all()

func _refresh_all() -> void:
	for t: int in _RES_ORDER:
		_labels[t].text = "%d" % int(Resources.get_resource(t))

func _on_resource_changed(type: int, new_amount: float) -> void:
	if _labels.has(type):
		_labels[type].text = "%d" % int(new_amount)
