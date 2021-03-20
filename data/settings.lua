if config.settings.y_tooltip_init then return end
config.settings.y_tooltip_init = true

-- config.settings.tome = config.settings.tome or {}

if type(config.settings.tome.y_tooltip_type) == 'nil' then
	config.settings.tome.y_tooltip_type = 'both'
end

if type(config.settings.tome.y_tooltip_size) == 'nil' then
	config.settings.tome.y_tooltip_size = 'both'
end

if type(config.settings.tome.y_tooltip_prodigy) == 'nil' then
	config.settings.tome.y_tooltip_prodigy = 'both'
end

if type(config.settings.tome.y_tooltip_manaburn) == 'nil' then
	config.settings.tome.y_tooltip_manaburn = 'both'
end

if type(config.settings.tome.y_tooltip_vim_gain) == 'nil' then
	config.settings.tome.y_tooltip_vim_gain = 'both'
end

config.settings.tome.y_tooltip_immunity_threshold = config.settings.tome.y_tooltip_immunity_threshold or 0
-- later
-- if type(config.settings.tome.y_tooltip_immunity_type) == "nil" then
-- 	config.settings.tome.y_tooltip_immunity_type = {"stun", "confusion", "poison", "disease", "blind", "silence", "disarm", "cut", "pin", "sleep", "fear", "knockback", "stone", "teleport", "instakill"}
-- end

config.settings.tome.y_tooltip_melee_ret_threshold = config.settings.tome.y_tooltip_melee_ret_threshold or 0

config.settings.tome.y_tooltip_crit_mult_threshold = config.settings.tome.y_tooltip_crit_mult_threshold or 150

config.settings.tome.y_tooltip_damage_mod_threshold = config.settings.tome.y_tooltip_damage_mod_threshold or 0

config.settings.tome.y_tooltip_damage_pen_threshold = config.settings.tome.y_tooltip_damage_pen_threshold or 0

config.settings.tome.y_tooltip_damage_resist_threshold = config.settings.tome.y_tooltip_damage_resist_threshold or 0

config.settings.tome.y_tooltip_damage_affinity_threshold = config.settings.tome.y_tooltip_damage_affinity_threshold or 0

if type(config.settings.tome.y_tooltip_faction) == 'nil' then
	config.settings.tome.y_tooltip_faction = 'both'
end

if type(config.settings.tome.y_tooltip_stealth) == 'nil' then
	config.settings.tome.y_tooltip_stealth = 'appropriate'
end
if type(config.settings.tome.y_tooltip_vs_stealth) == 'nil' then
	config.settings.tome.y_tooltip_vs_stealth = 'both'
end

if type(config.settings.tome.y_tooltip_flavor_text) == 'nil' then
	config.settings.tome.y_tooltip_flavor_text = 'both'
end

if type(config.settings.tome.y_tooltip_killed_by_you) == 'nil' then
	config.settings.tome.y_tooltip_killed_by_you = 'both'
end
