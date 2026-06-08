## Displays active status effects for a CombatEntity as colored chips.
## Call bind(entity) once; it auto-refreshes on every status change.
class_name StatusEffectDisplay
extends HBoxContainer

const STATUS_COLORS: Dictionary = {
	"strength":    Color(1.00, 0.55, 0.05),
	"dexterity":   Color(0.30, 0.85, 0.45),
	"vulnerable":  Color(0.90, 0.25, 0.25),
	"weak":        Color(0.50, 0.50, 1.00),
	"frail":       Color(0.85, 0.75, 0.30),
	"poison":      Color(0.40, 0.85, 0.20),
}

const STATUS_LABELS: Dictionary = {
	"strength":   "STR",
	"dexterity":  "DEX",
	"vulnerable": "VUL",
	"weak":       "WEK",
	"frail":      "FRL",
	"poison":     "PSN",
}

const STATUS_TOOLTIPS: Dictionary = {
	"strength":   "Strength: increases attack damage",
	"dexterity":  "Dexterity: increases block gained",
	"vulnerable": "Vulnerable: take 50%% more damage",
	"weak":       "Weak: deal 25%% less damage",
	"frail":      "Frail: gain 25%% less block",
	"poison":     "Poison: take damage each turn, then lose 1 stack",
}

func bind(entity: CombatEntity) -> void:
	entity.status_applied.connect(func(_s, _v): _refresh(entity))
	entity.health_changed.connect(func(_c, _m): _refresh(entity))
	_refresh(entity)

func _refresh(entity: CombatEntity) -> void:
	for child in get_children():
		child.queue_free()

	for status: String in entity.statuses:
		var stacks: int = entity.statuses[status]
		if stacks <= 0:
			continue
		_add_chip(status, stacks)

func _add_chip(status: String, stacks: int) -> void:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_PASS
	chip.tooltip_text = STATUS_TOOLTIPS.get(status, status.capitalize())

	# Tint the panel background
	var style := StyleBoxFlat.new()
	style.bg_color = STATUS_COLORS.get(status, Color.GRAY).darkened(0.3)
	style.border_color = STATUS_COLORS.get(status, Color.GRAY)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 4
	style.content_margin_right  = 4
	style.content_margin_top    = 2
	style.content_margin_bottom = 2
	chip.add_theme_stylebox_override("panel", style)

	var lbl := Label.new()
	lbl.text = "%s %d" % [STATUS_LABELS.get(status, status.left(3).to_upper()), stacks]
	lbl.add_theme_color_override("font_color", STATUS_COLORS.get(status, Color.WHITE))
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(lbl)

	add_child(chip)
