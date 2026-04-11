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

func initialize(game_ctrl: Node) -> void:
	_game = game_ctrl
	_build_title()
	_build_resource_strip()
	_build_decree_panel()
	_build_event_log()
	_build_raid_banner()

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

func push_event(text: String, color: Color = Color.WHITE) -> void:
	if _event_log and _event_log.has_method("push"):
		_event_log.push(text, color)

func show_raid_banner(title: String, subtitle: String, color: Color) -> void:
	if _raid_banner and _raid_banner.has_method("show_raid"):
		_raid_banner.show_raid(title, subtitle, color)

func hide_raid_banner() -> void:
	if _raid_banner and _raid_banner.has_method("hide_raid"):
		_raid_banner.hide_raid()
