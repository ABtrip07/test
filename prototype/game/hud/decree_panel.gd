extends Control

## Right-side decree panel. Four big fantasy buttons: Gather, Build, Raid, Recruit.
## Clicking a button calls back into the GameController.

var _game: Node
var _panel: PanelContainer
var _vbox: VBoxContainer

func initialize(game_ctrl: Node) -> void:
	_game = game_ctrl
	_build_ui()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.10, 0.08, 0.06, 0.78)
	sb.border_color = Color(0.65, 0.48, 0.2, 0.92)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(_vbox)

	var title: Label = Label.new()
	title.text = "~ Royal Decrees ~"
	title.add_theme_color_override("font_color", Color(1, 0.88, 0.55))
	title.add_theme_font_size_override("font_size", 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_vbox.add_child(title)

	_add_button("[1] Gather Scrap", Color(0.55, 0.9, 0.55), "_gather")
	_add_button("[2] Build", Color(0.55, 0.75, 1.0), "_build")
	_add_button("[3] RAID Enemy Base", Color(1.0, 0.55, 0.45), "_raid")
	_add_button("[4] Recruit Levies", Color(1.0, 0.85, 0.55), "_recruit")

	var hint: Label = Label.new()
	hint.text = "[G] Drop in as God-King"
	hint.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	hint.add_theme_font_size_override("font_size", 12)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_vbox.add_child(hint)

func _add_button(label: String, tint: Color, method: String) -> void:
	var btn: Button = Button.new()
	btn.text = label
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 0.95, 0.7))
	btn.add_theme_font_size_override("font_size", 15)
	var sb_normal: StyleBoxFlat = StyleBoxFlat.new()
	sb_normal.bg_color = tint.darkened(0.45)
	sb_normal.border_color = tint
	sb_normal.set_border_width_all(2)
	sb_normal.set_corner_radius_all(4)
	sb_normal.content_margin_left = 10
	sb_normal.content_margin_right = 10
	sb_normal.content_margin_top = 6
	sb_normal.content_margin_bottom = 6
	var sb_hover: StyleBoxFlat = sb_normal.duplicate()
	sb_hover.bg_color = tint.darkened(0.2)
	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_hover)
	btn.pressed.connect(Callable(self, method))
	_vbox.add_child(btn)

func _gather() -> void:
	if _game and _game.has_method("trigger_gather_decree"):
		_game.trigger_gather_decree()

func _build() -> void:
	if _game and _game.has_method("trigger_build_decree"):
		_game.trigger_build_decree()

func _raid() -> void:
	if _game and _game.has_method("trigger_raid_decree"):
		_game.trigger_raid_decree()

func _recruit() -> void:
	if _game and _game.has_method("trigger_recruit_decree"):
		_game.trigger_recruit_decree()
