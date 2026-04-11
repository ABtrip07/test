class_name FactionPalette

## Cartoon fantasy color palette for the three MVP clans.
## Warm, saturated, storybook tones.

const CHOSEN := &"chosen"
const RIVAL := &"rival_salvagers"
const NEUTRAL := &"neutral_wasters"

## Villager body + banner color for each clan.
static func primary_color(clan_id: StringName) -> Color:
	match clan_id:
		CHOSEN: return Color(0.30, 0.55, 0.95)   # royal blue
		RIVAL: return Color(0.90, 0.30, 0.25)    # vermilion red
		NEUTRAL: return Color(0.70, 0.60, 0.45)  # wheat/tan
	return Color(0.5, 0.5, 0.5)

## Lot ground tint.
static func ground_color(clan_id: StringName) -> Color:
	match clan_id:
		CHOSEN: return Color(0.30, 0.55, 0.25)    # player grass, a bit bluer-green
		RIVAL: return Color(0.45, 0.38, 0.22)     # rival: scorched/darker dirt
		NEUTRAL: return Color(0.40, 0.55, 0.28)   # neutral: plain meadow
	return Color(0.35, 0.50, 0.25)

## Owner ring glow color.
static func ring_color(clan_id: StringName) -> Color:
	match clan_id:
		CHOSEN: return Color(0.5, 0.75, 1.0)
		RIVAL: return Color(1.0, 0.5, 0.3)
		NEUTRAL: return Color(0.95, 0.9, 0.7)
	return Color(0.8, 0.8, 0.8)

## Accent color for banners, flags, accents.
static func accent_color(clan_id: StringName) -> Color:
	match clan_id:
		CHOSEN: return Color(0.95, 0.85, 0.3)     # gold
		RIVAL: return Color(0.15, 0.1, 0.1)       # blackened wood
		NEUTRAL: return Color(0.85, 0.8, 0.7)
	return Color(0.7, 0.7, 0.7)

static func clan_display_name(clan_id: StringName) -> String:
	match clan_id:
		CHOSEN: return "The Sigil"
		RIVAL: return "The Quantists"
		NEUTRAL: return "The Wasters"
	return String(clan_id)
