class_name EffectResolver
extends Node

# Resolves a card's effects array against source/target entities.
# Each effect dict: { "effect": String, "value": int }

func resolve(effects: Array[Dictionary], source: CombatEntity, target: CombatEntity) -> void:
	for effect in effects:
		_apply(effect, source, target)

func _apply(effect: Dictionary, source: CombatEntity, target: CombatEntity) -> void:
	var name: String = effect.get("effect", "")
	var value: int = effect.get("value", 0)

	match name:
		"damage":
			var dmg := _calc_damage(value, source, target)
			target.take_damage(dmg)

		"damage_multi":
			# hits: number of strikes, value: damage per hit
			var hits: int = effect.get("hits", 1)
			var dmg := _calc_damage(value, source, target)
			for _i in hits:
				target.take_damage(dmg)

		"block":
			var block := _calc_block(value, source)
			source.gain_block(block)

		"heal":
			source.heal(value)

		"draw":
			# Signal back to CombatManager to draw cards; handled via signal
			draw_requested.emit(value)

		"gain_energy":
			energy_requested.emit(value)

		"apply_vulnerable":
			target.apply_status("vulnerable", value)

		"apply_weak":
			target.apply_status("weak", value)

		"apply_frail":
			source.apply_status("frail", value)

		"gain_strength":
			source.apply_status("strength", value)

		"gain_dexterity":
			source.apply_status("dexterity", value)

		"apply_poison":
			target.apply_status("poison", value)

		"damage_equal_to_block":
			var dmg := _calc_damage(source.block, source, target)
			target.take_damage(dmg)

		_:
			push_warning("EffectResolver: unknown effect '%s'" % name)

func _calc_damage(base: int, source: CombatEntity, target: CombatEntity) -> int:
	var dmg := base + source.get_strength()
	if source.get_status("weak") > 0:
		dmg = int(dmg * 0.75)
	return maxi(0, dmg)

func _calc_block(base: int, source: CombatEntity) -> int:
	var blk := base + source.get_status("dexterity")
	if source.get_status("frail") > 0:
		blk = int(blk * 0.75)
	return maxi(0, blk)

signal draw_requested(count: int)
signal energy_requested(amount: int)
