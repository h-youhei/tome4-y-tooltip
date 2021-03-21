require "engine.class"

local KeyBind = require "engine.KeyBind"

class:bindHook("ToME:load", function(self, data)
	KeyBind:defineAction{
		default = { "sym:=c:false:false:true:false" },
		type = "SHOW_CHARACTER_SHEET_TALENT_CURSOR",
		group = "actions",
		name = _t"Show character talents (actor @ cursor)",
	}
end)

dofile("/data-y-tooltip/settings.lua")

class:bindHook("GameOptions:tabs", function(self, data)
	data.tab("[Y Tooltip]", function() self.list = {y_tooltip_options=true} end)
end)

class:bindHook("GameOptions:generateList", function(self, data)
	if not data.list.y_tooltip_options then return end
	local Textzone = require "engine.ui.Textzone"
	local GetQuantity = require "engine.dialogs.GetQuantity"
	local Dialog = require "engine.ui.Dialog"

	local list = data.list
	-- local function createBoolOption(option, title, desc, defStatus, defFunc)
	-- 	defStatus = defStatus or function(item)
	-- 		return tostring(config.settings.tome["y_tooltip_"..option] and "enabled" or "disabled")
	-- 	end
	-- 	defFunc = defFunc or function(item)
	-- 		config.settings.tome["y_tooltip_"..option] = not config.settings.tome["y_tooltip"..option]
	-- 		game:saveSettings("tome.y_tooltip_"..option, ("tome.y_tooltip_"..option.." = %q\n"):format(tostring(config.settings.tome["y_tooltip_"..option])))
	-- 		self.c_list:drawItem(item)
	-- 	end
	-- 	list[#list+1] = {
	-- 		zone=Textzone.new{
	-- 			width=self.c_desc.w, height=self.c_desc.h,
	-- 			text=string.toTString(desc)
	-- 		},
	-- 		name=string.toTString(("#GOLD##{bold}#%s#WHITE##{normal}#"):tformat(title)),
	-- 		status=defStatus,
	-- 		fct=defFunc
	-- 	}
	-- end

	local function createDisplayOption(option, title, desc, defStatus, defFunc)
		defStatus = defStatus or function(item)
			local v = { both=_t'Both', normal=_t'Normal', ctrl=_t'Ctrl', neither=_t'Neither' }
			return v[config.settings.tome["y_tooltip_"..option]] or _t'Both'
		end
		defFunc = defFunc or function(item)
			local entries = {
				{name=_t'Both', tag='both'},
				{name=_t'Normal', tag='normal'},
				{name=_t'Ctrl', tag='ctrl'},
				{name=_t'Neither', tag='neither'}
			}
			Dialog:listPopup(title, _t'Select behavior', entries, 400, 200, function(sel)
				if not sel or not sel.tag then return end
				config.settings.tome["y_tooltip_"..option] = sel.tag
				game:saveSettings("tome.y_tooltip_"..option, ("tome.y_tooltip_"..option.." = %q\n"):format(sel.tag))
				self.c_list:drawItem(item)
			end)
		end
		list[#list+1] = {
			zone=Textzone.new{
				width=self.c_desc.w, height=self.c_desc.h,
				text=string.toTString(desc..[[


- #LIGHT_BLUE#Both#LAST#: show if appropriate whether Ctrl is pressed or not.
- #LIGHT_BLUE#Normal#LAST#: show only when Ctrl is not pressed.
- #LIGHT_BLUE#Ctrl#LAST#: show only when Ctrl is pressed.
- #LIGHT_BLUE#Neither#LAST#: do not show whether Ctrl is pressed or not.]])
			},
			name=string.toTString(("#GOLD##{bold}#%s#WHITE##{normal}#"):tformat(title)),
			status=defStatus,
			fct=defFunc
		}
	end
	-- show only if appropriate. but sometimes want to see the info regardless of conditions.
	-- so make it visible by pressing ctrl
	local function createConditionalOption(option, title, desc, cond_desc, defStatus, defFunc)
		defStatus = defStatus or function(item)
			local v = { always=_t'Always', appropriate=_t'Appropriate', never=_t'Never' }
			return v[config.settings.tome["y_tooltip_"..option]] or _t'Appropriate'
		end
		defFunc = defFunc or function(item)
			local entries = {
				{name=_t'Always', tag='always'},
				{name=_t'Appropriate', tag='appropriate'},
				{name=_t'Never', tag='never'}
			}
			Dialog:listPopup(title, _t'Select behavior', entries, 400, 200, function(sel)
				if not sel or not sel.tag then return end
				config.settings.tome["y_tooltip_"..option] = sel.tag
				game:saveSettings("tome.y_tooltip_"..option, ("tome.y_tooltip_"..option.." = %q\n"):format(sel.tag))
				self.c_list:drawItem(item)
			end)
		end
		list[#list+1] = {
			zone=Textzone.new{
				width=self.c_desc.w, height=self.c_desc.h,
				text=string.toTString(desc..[[


- #LIGHT_BLUE#Always#LAST#: always show.
- #LIGHT_BLUE#Appropriate#LAST#: ]]..cond_desc..[[

- #LIGHT_BLUE#Never#LAST#: never show.]])
			},
			name=string.toTString(("#GOLD##{bold}#%s#WHITE##{normal}#"):tformat(title)),
			status=defStatus,
			fct=defFunc
		}
	end
	local function createNumericalOption(option, title, desc, prompt, minVal, maxVal, defStatus, defFunc)
		minVal = minVal or 0
		maxVal = maxVal or 999
		defStatus = defStatus or function(item)
			return tostring(config.settings.tome["y_tooltip_"..option] or "-")
		end
		defFunc = defFunc or function(item)
			game:registerDialog(GetQuantity.new(prompt, "From "..minVal.." to "..maxVal, config.settings.tome["y_tooltip_"..option] or minVal, maxVal, function(qty)
				config.settings.tome["y_tooltip_"..option] = qty
				game:saveSettings("tome.y_tooltip_"..option, ("tome.y_tooltip_"..option.." = %s\n"):format(tostring(config.settings.tome["y_tooltip_"..option])))
				self.c_list:drawItem(item)
			end))
		end
		list[#list+1] = {
			zone=Textzone.new{
				width=self.c_desc.w, height=self.c_desc.h,
				text=string.toTString(desc)
			},
			name=string.toTString(("#GOLD##{bold}#%s#WHITE##{normal}#"):format(title)),
			status=defStatus,
			fct=defFunc
		}
	end

	createDisplayOption("type", "Show Type", [[Whether to display Character Type and Gender.]])

	createConditionalOption("size", "Show Size", [[Whether to display Character Size.]],
		[[show only when size related Talents are involved. Even when not you can check size by pressing Ctrl.)

	createDisplayOption("prodigy", "Show Prodigies", [[Whether to display Prodigies.]])

	createDisplayOption("manaburn", "Show Manaburnable Resources", [[Whether to show enemy's Mana, Vim, Positiveand Negative resources if player follow antimagic.]])

	createDisplayOption("vim_gain", "Show Vim Gain", [[Whether to display Vim Gain after kill.]])

	createNumericalOption("immunity_threshold", "Immunity Threshold",
		[[Show the immunity greater than this value.
If set to very high value, Immunities are never shown.
0 is used as threshold regardless of this value while Ctrl is pressed.]],
		"Percent")

	createNumericalOption("crit_mult_threshold", "Crit Mult Threshold",
		[[Show Critical Multiplier if it is greater than this value.
If set to very high value, Critical Multiplier is never shown.
150 is used as the threshold regardless of this value while Ctrl is pressed.]],
		"Percent", 150, 9999)

	createNumericalOption("melee_ret_threshold", "Melee Retaliation Threshold",
		[[Show Melee Retaliation if it is greater than this percent of player's max life.
If set to very high value, Melee Retaliation is never shown.
0 is used as the threshold regardless of this value while Ctrl is pressed.]],
		"Damage")

	createNumericalOption("damage_mod_threshold", "Damage Modifiers Threshold",
		[[Show Damage Modifiers if each of its absolute value is greater than this value.
If set to very high value, Damage Modifiers is never shown.
0 is used as the threshold regardless of this value while Ctrl is pressed.]],
		"Percent", 0, 99999)

	createNumericalOption("damage_pen_threshold", "Damage Penetrations Threshold",
		[[Show Damage Penetrations if each of its value is greater than this value.
If set to very high value, Damage Penetrations is never shown.
0 is used as the threshold regardless of this value while Ctrl is pressed.]],
		"Percent", 0, 9999)

	createNumericalOption("damage_resist_threshold", "Damage Resistances Threshold",
		[[Show Damage Resistances if each of its absolute value is greater than this value.
If set to very high value, Damage Resistances is never shown.
0 is used as the threshold regardless of this value while Ctrl is pressed.]],
		"Percent", 0, 9999)
	createNumericalOption("damage_affinity_threshold", "Damage Affinities Threshold",
		[[Show Damage Affinities if each of its value is greater than this value.
If set to very high value, Damage Affinities is never shown.
0 is used as the threshold regardless of this value while Ctrl is pressed.]],
		"Percent", 0, 9999)

	createDisplayOption("faction", "Show Faction", [[Whether to display Faction and Personal Reaction.]])

	createConditionalOption("stealth", "Show Stealth/Invisible helper",
		[[Whether to display information that helps player when using Stealth or Invisible. That is your Stealth/Invisible value and enemy's See Stealth/Invisible.]],
		[[show only when player is stealthed or invisible. Even when not you can check Enemy's See Stealth/Invisible while player is not stealthed or invisible by pressing Ctrl.]])

	createDisplayOption("vs_stealth", "Show vs Stealth/Invisible", [[Whether to display information that helps player when fighting Stealthed/Invisible enemies. That is your See Stealth/Invisible and enemy's Stealth/Invisible value.]])

	createDisplayOption("flavor_text", "Show Flavor text", [[Whether to display Flavor text.]])

	createDisplayOption("killed_by_you", "Show Killed by you", [[Whether to display Killed by you.]])
end)
