extends Control

## Scrolling event log in bottom-left. Shows most recent 8 events.

const _MAX_LINES: int = 8

var _panel: PanelContainer
var _vbox: VBoxContainer

func _ready() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.07, 0.05, 0.72)
	sb.border_color = Color(0.5, 0.38, 0.18, 0.85)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 2)
	_panel.add_child(_vbox)

	var title: Label = Label.new()
	title.text = "~ Chronicle ~"
	title.add_theme_color_override("font_color", Color(1, 0.88, 0.55))
	title.add_theme_font_size_override("font_size", 13)
	_vbox.add_child(title)

func push(text: String, color: Color = Color.WHITE) -> void:
	if _vbox == null:
		return
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(420, 0)
	_vbox.add_child(lbl)
	# Trim to last MAX_LINES entries (keeping the title at index 0)
	while _vbox.get_child_count() > _MAX_LINES + 1:
		var doomed: Node = _vbox.get_child(1)
		_vbox.remove_child(doomed)
		doomed.queue_free()
