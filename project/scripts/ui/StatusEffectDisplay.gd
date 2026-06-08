## Displays status effect icons+stacks for a CombatEntity.
class_name StatusEffectDisplay
extends HBoxContainer

const STATUS_COLORS := {
	"vulnerable": Color(1.0, 0.4, 0.4),
	"weak": Color(0.6, 0.6, 1.0),
	"frail": Color(0.8, 0.7, 0.4),
	"strength": Color(1.0, 0.6, 0.0),
	"dexterity": Color(0.4, 0.9, 0.5),
	"poison": Color(0.5, 0.9, 0.3),
}

const STATUS_ICONS := {
	"vulnerable": "V",
	"weak": "W",
	"frail": "F",
	"strength": "S",
	"dexterity": "D",
	"poison": "P",
}

func refresh(entity: CombatEntity) -> void:
	for child in get_children():
		child.queue_free()

	for status in entity.statuses:
		var stacks: int = entity.statuses[status]
		if stacks <= 0:
			continue
		var lbl := Label.new()
		lbl.text = "%s%d" % [STATUS_ICONS.get(status, "?"), stacks]
		lbl.add_theme_color_override("font_color", STATUS_COLORS.get(status, Color.WHITE))
		lbl.tooltip_text = status.capitalize() + ": " + str(stacks)
		add_child(lbl)
