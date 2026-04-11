extends Control

## Dramatic banner that appears when a raid is live. Pulses briefly.

var _panel: PanelContainer
var _title: Label
var _subtitle: Label
var _hide_timer: float = 0.0

func _ready() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.25, 0.06, 0.04, 0.85)
	sb.border_color = Color(1.0, 0.5, 0.3, 1.0)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	var vb: VBoxContainer = VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_child(vb)

	_title = Label.new()
	_title.text = "RAID!"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_color_override("font_color", Color(1, 0.82, 0.3))
	_title.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.0))
	_title.add_theme_constant_override("outline_size", 4)
	_title.add_theme_font_size_override("font_size", 22)
	vb.add_child(_title)

	_subtitle = Label.new()
	_subtitle.text = ""
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	_subtitle.add_theme_font_size_override("font_size", 14)
	vb.add_child(_subtitle)

	set_process(true)

func show_raid(title: String, subtitle: String, color: Color) -> void:
	visible = true
	_title.text = title
	_title.add_theme_color_override("font_color", color)
	_subtitle.text = subtitle
	modulate = Color(1, 1, 1, 0.0)
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	_hide_timer = 4.5

func hide_raid() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1, 0.0), 0.4)
	tw.tween_callback(func(): visible = false)

func _process(delta: float) -> void:
	if _hide_timer > 0.0:
		_hide_timer -= delta
		if _hide_timer <= 0.0:
			hide_raid()
