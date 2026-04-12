extends CanvasLayer

## HUD root. Holds the resource strip, event log, decree panel, and raid banner.
## GameController calls `initialize(game_ctrl)` then pushes events via `push_event`.

const ResourceStripScript := preload("res://game/hud/resource_strip.gd")
const EventLogScript := preload("res://game/hud/event_log.gd")
const DecreePanelScript := preload("res://game/hud/decree_panel.gd")
const RaidBannerScript := preload("res://game/hud/raid_banner.gd")

var _game: Node
var _resource_strip: Control
var _event_log: Control
var _decree_panel: Control
var _raid_banner: Control
var _title: Label
var _gk_hp_bar: ProgressBar
var _gk_hp_label: Label
var _gk_hp_panel: PanelContainer

func initialize(game_ctrl: Node) -> void:
	_game = game_ctrl
	_build_title()
	_build_resource_strip()
	_build_decree_panel()
	_build_event_log()
	_build_raid_banner()
	_build_gk_hp_bar()

func _build_title() -> void:
	_title = Label.new()
	_title.text = "The Last Collective"
	_title.add_theme_font_size_override("font_size", 22)
	_title.add_theme_color_override("font_color", Color(1, 0.95, 0.78))
	_title.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.05))
	_title.add_theme_constant_override("outline_size", 4)
	_title.anchor_left = 0.5
	_title.anchor_right = 0.5
	_title.offset_left = -140
	_title.offset_top = 8
	_title.offset_right = 140
	_title.offset_bottom = 40
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_title)

func _build_resource_strip() -> void:
	_resource_strip = Control.new()
	_resource_strip.set_script(ResourceStripScript)
	_resource_strip.anchor_left = 0.0
	_resource_strip.anchor_top = 0.0
	_resource_strip.offset_left = 16
	_resource_strip.offset_top = 12
	_resource_strip.offset_right = 520
	_resource_strip.offset_bottom = 54
	add_child(_resource_strip)
	if _resource_strip.has_method("initialize"):
		_resource_strip.initialize()

func _build_decree_panel() -> void:
	_decree_panel = Control.new()
	_decree_panel.set_script(DecreePanelScript)
	_decree_panel.anchor_left = 1.0
	_decree_panel.anchor_top = 0.0
	_decree_panel.anchor_right = 1.0
	_decree_panel.offset_left = -300
	_decree_panel.offset_top = 60
	_decree_panel.offset_right = -16
	_decree_panel.offset_bottom = 280
	add_child(_decree_panel)
	if _decree_panel.has_method("initialize"):
		_decree_panel.initialize(_game)

func _build_event_log() -> void:
	_event_log = Control.new()
	_event_log.set_script(EventLogScript)
	_event_log.anchor_left = 0.0
	_event_log.anchor_top = 1.0
	_event_log.anchor_right = 0.0
	_event_log.anchor_bottom = 1.0
	_event_log.offset_left = 16
	_event_log.offset_top = -210
	_event_log.offset_right = 460
	_event_log.offset_bottom = -16
	add_child(_event_log)

func _build_raid_banner() -> void:
	_raid_banner = Control.new()
	_raid_banner.set_script(RaidBannerScript)
	_raid_banner.anchor_left = 0.5
	_raid_banner.anchor_right = 0.5
	_raid_banner.anchor_top = 0.0
	_raid_banner.offset_left = -220
	_raid_banner.offset_top = 48
	_raid_banner.offset_right = 220
	_raid_banner.offset_bottom = 108
	_raid_banner.visible = false
	add_child(_raid_banner)

func _build_gk_hp_bar() -> void:
	_gk_hp_panel = PanelContainer.new()
	_gk_hp_panel.anchor_left = 0.5
	_gk_hp_panel.anchor_right = 0.5
	_gk_hp_panel.anchor_top = 1.0
	_gk_hp_panel.anchor_bottom = 1.0
	_gk_hp_panel.offset_left = -160
	_gk_hp_panel.offset_top = -60
	_gk_hp_panel.offset_right = 160
	_gk_hp_panel.offset_bottom = -20
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.06, 0.04, 0.8)
	sb.border_color = Color(0.85, 0.65, 0.2, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	_gk_hp_panel.add_theme_stylebox_override("panel", sb)
	_gk_hp_panel.visible = false
	add_child(_gk_hp_panel)
	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	_gk_hp_panel.add_child(vb)
	_gk_hp_label = Label.new()
	_gk_hp_label.text = "GOD-KING"
	_gk_hp_label.add_theme_font_size_override("font_size", 11)
	_gk_hp_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.5))
	_gk_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_gk_hp_label)
	_gk_hp_bar = ProgressBar.new()
	_gk_hp_bar.min_value = 0.0
	_gk_hp_bar.max_value = 110.0
	_gk_hp_bar.value = 110.0
	_gk_hp_bar.show_percentage = false
	_gk_hp_bar.custom_minimum_size = Vector2(280, 16)
	var fg: StyleBoxFlat = StyleBoxFlat.new()
	fg.bg_color = Color(0.3, 0.85, 0.4)
	fg.set_corner_radius_all(3)
	_gk_hp_bar.add_theme_stylebox_override("fill", fg)
	var bg: StyleBoxFlat = StyleBoxFlat.new()
	bg.bg_color = Color(0.2, 0.12, 0.08)
	bg.set_corner_radius_all(3)
	_gk_hp_bar.add_theme_stylebox_override("background", bg)
	vb.add_child(_gk_hp_bar)

func show_gk_hp(hp: float, max_hp: float) -> void:
	if _gk_hp_panel == null:
		return
	_gk_hp_panel.visible = true
	_gk_hp_bar.max_value = max_hp
	_gk_hp_bar.value = hp
	_gk_hp_label.text = "GOD-KING  %d / %d" % [int(hp), int(max_hp)]
	# Color shifts red as HP drops.
	var r: float = clampf(hp / max_hp, 0.0, 1.0)
	var fg: StyleBoxFlat = _gk_hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fg:
		fg.bg_color = Color(1.0 - r, r * 0.85, 0.3)

func hide_gk_hp() -> void:
	if _gk_hp_panel:
		_gk_hp_panel.visible = false

func push_event(text: String, color: Color = Color.WHITE) -> void:
	if _event_log and _event_log.has_method("push"):
		_event_log.push(text, color)

func show_raid_banner(title: String, subtitle: String, color: Color) -> void:
	if _raid_banner and _raid_banner.has_method("show_raid"):
		_raid_banner.show_raid(title, subtitle, color)

func hide_raid_banner() -> void:
	if _raid_banner and _raid_banner.has_method("hide_raid"):
		_raid_banner.hide_raid()
