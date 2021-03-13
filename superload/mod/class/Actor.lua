-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Faction = require "engine.Faction"
local DamageType = require "engine.DamageType"
--local Actor = require "engine.Actor"

local _M = loadPrevious(...)

local function colorPercent(percent, offset)
	local offset = offset or 0
	if percent < offset then
		return "#LIGHT_RED#"
	else
		return "#WHITE#"
	end
end

local function addDamageList(ts, list)
	table.sort(list, function(a, b)
		if a.type == "all" then return true
		elseif b.type == "all" then return false
		elseif a.type == "absolute" then return true
		elseif b.type == "absolute" then return false
		else return a.v > b.v
		end
	end)
	local first = true
	for _, t in pairs(list) do
		if not first then ts:add(",") end
		first = false
		if t.type == "all" then
			ts:add((" All %s%d%%"):tformat(colorPercent(t.v), t.v))
		elseif t.type == "absolute" then
			ts:add((" #SALMON#Absolute %s%d%%"):tformat(colorPercent(t.v), t.v))
		else
			local dt = DamageType:get(t.type)
			local color = dt.text_color or "#WHITE#"
			-- change colors that hard to see
			if t.type == "ARCANE" then
				-- from #PURPLE#
				color = "#DARK_ORCHID#"
			elseif t.type == "COLD" then
				-- from #1133F3#
				color = "#LIGHT_BLUE#"
			elseif t.type == "BLIGHT" then
				-- from #DARK_GREEN#
				color = "#OLIVE_DRAB#"
			end
			ts:add((" %s%s %s%d%%"):tformat(color, dt.name:capitalize(), colorPercent(t.v), t.v))
		end
	end
	ts:add({"color", "WHITE"}, true)
end

local function addWeapon(ts, o, stats, txt)
	ts:add("#LIGHT_BLUE#", txt, ":#LAST#")
	ts:add((" #RED#%d#LAST#"):tformat(math.floor(stats.dmg)))
	ts:add((", APR %d"):tformat(stats.apr))
	ts:add((", Crit %d%%"):tformat(stats.crit))
	if stats.range and stats.range > 1 then
		ts:add((", Range %d"):tformat(stats.range))
	end
	ts:add(true)
	if o then
		local tst = o:getShortName({force_id=true, do_color=true, no_add_name=true}):toTString()
		tst = tst:splitLines(game.tooltip.max-1, game.tooltip.font, 2)
		tst = tst:extractLines(true)[1]
		ts:add(" ")
		table.append(ts, tst)
		ts:add(true)
	end
end

function _M:tooltip(x, y, seen_by)
	local ctrl = core.key.modState("ctrl")

	if seen_by and not seen_by:canSee(self) then return end
	-- Debug feature, mousing over with ctrl pressed will give detailed FOV info
	if config.settings.cheat and core.key.modState("ctrl") then
		print("============================================== SEEING from", self.name)
		for i, a in ipairs(self.fov.actors_dist) do
			local d = self.fov.actors[a]
			if d then
				print(("%3d : %-40s at %3dx%3d (see at %3dx%3d), diff %3dx%3d"):format(d.sqdist, a.name, a.x, a.y, d.x, d.y,d.dx,d.dy))
			end
		end
		print("==============================================")
	end

	local rank, rank_color = self:TextRank()

	local ts = tstring{}
	-- name (range)
	-- name
	ts:add({"uid",self.uid}) ts:merge(rank_color:toTString()) ts:add(self:getName(), {"color", "WHITE"})
	-- DEL: sex
	-- if self.type == "humanoid" or self.type == "giant" then ts:add({"font","italic"}, "(", self.female and _t"female" or _t"male", ")", {"font","normal"}, true) else ts:add(true) end
	-- race or type / subrace or subtype / size
	-- range
	if game.player.x and game.player.y and x and y then
		ts:add(_t" (range: ", {"font", "italic"}, {"color", "LIGHT_GREEN"}, tostring(core.fov.distance(game.player.x, game.player.y, x, y)), {"color", "LAST"}, {"font", "normal"}, ")")
	end
	ts:add(true)

	-- race or type (size)
	-- MOD: remove linebreak
	ts:add(_t(self.type):capitalize(), " / ", _t(self.subtype):capitalize(), " ")
	-- MOV: size
	ts:add({"font", "italic"}, "(", self:TextSizeCategory(), ")", {"font", "normal"}, true)

	-- level rank
	-- level
	if self.hide_level_tooltip then ts:add({"color", 0, 255, 255}, "Level: unknown", {"color", "WHITE"})
	else ts:add({"color", 0, 255, 255}, ("Level: %d"):tformat(self.level), {"color", "WHITE"}) end
	-- MOV: rank
	ts:add("  ")
	ts:merge(rank_color:toTString())
	ts:add(rank, {"color", "WHITE"},true)

	-- invulnerability
	if self:attr("invulnerable") then ts:add({"color", "PURPLE"}, "INVULNERABLE!", true) end

	-- hp (ratio) +regen (+heal mod) [die]
	-- hp
	ts:add({"color", 255, 0, 0}, ("HP: %d (%d%%)"):tformat(self.life, self.life * 100 / self.max_life), {"color", "WHITE"})
	-- ADD: regen
	ts:add((" #GREEN#+%0.2f#LAST#"):tformat(self.life_regen * util.bound(self.healing_factor or 1)))
	-- healmod
	local pvalue = util.bound((self.healing_factor or 1), 0, 2.5)
	ts:add(pvalue<1 and {"color","LIGHT_RED"} or {"color","LIGHT_GREEN"}, " (", tostring(math.floor(pvalue*100)),"%)",{"color","WHITE"})
	-- negative life
	if self.die_at and self.die_at ~= 0 then ts:add({"color", 150, 150, 150}, (" [die:%d]"):tformat(self.die_at)) end
	ts:add(true)

	-- psi if solipsism
	if self:knowTalent(self.T_SOLIPSISM) then
		local psi_percent = 100*self.psi/self.max_psi
		ts:add((("#7fffd4#Psi: %d")):format(self.psi), (" (%d%%)"):tformat(psi_percent),{"color", "WHITE"}, true)
	end
	-- MAYBE: shield
	-- if self:attr("damage_shield") then
	-- 	local eff = self:hasEffect(self.EFF_DAMAGE_SHIELD)
	-- 	ts:add(("Shield: %d / %d"):tformat(?, eff.power), {"color", "WHITE"})
	-- end

	-- iceblock
	if self:attr("encased_in_ice") then
		local eff = self:hasEffect(self.EFF_FROZEN)
		ts:add({"color", 0, 255, 128}, ("Iceblock: %d"):tformat(eff.hp), {"color", "WHITE"}, true)
	end

	-- mana burnable resources
	-- Avoid cluttering tooltip if resources aren't relevant (add menu option?)
	if game.player:knowTalentType("wild-gift/antimagic") then
		local count = 0
		if self:knowTalent(self.T_MANA_POOL) then
			ts:add(("%sMana: %d / %d  #LAST#"):tformat(self.resources_def.mana.color, self.mana, self.max_mana))
			count = count+1
		end
		if self:knowTalent(self.T_VIM_POOL) then
			-- from vim.color #904010
			ts:add(("%sVim: %d / %d#LAST#"):tformat("#B04810#", self.vim, self.max_vim))
			count = count+1
		end
		if count>0 then ts:add(true) end
		count = 0
		if self:knowTalent(self.T_POSITIVE_POOL) then
			ts:add(("%sPos: %d / %d  #LAST#"):tformat(self.resources_def.positive.color, self.positive, self.max_positive))
			count = count+1
		end
		if self:knowTalent(self.T_NEGATIVE_POOL) then
			ts:add(("%sNeg: %d / %d#LAST#"):tformat(self.resources_def.negative.color,self.negative, self.max_negative))
			count = count+1
		end
		if count > 0 then ts:add(true) end
	end

	-- summon timer
	if self.summon_time then
		ts:add("Summon Time left: ", {"color", "ANTIQUE_WHITE"}, ("%d"):format(self.summon_time), {"color", "WHITE"}, true)
	end

	-- vim gain after kill
	if game.player:knowTalent(self.T_VIM_POOL) and self ~= game.player then
		-- vim.color #904010
		ts:add(("%sVim Gain: %d"):tformat("#B04810#", (game.player:getWil() * 0.5 + 1) * self.rank), {"color", "WHITE"}, true)
	end

	-- predator
	if game.player:knowTalent(self.T_PREDATOR) then
		local predatorcount = game.player.predator_type_history and game.player.predator_type_history[self.type] or 0
		local tp = game.player:getTalentFromId(game.player.T_PREDATOR)
		local predatorATK = tp.getATK(game.player, tp) * predatorcount
		local predatorAPR = tp.getAPR(game.player, tp) * predatorcount
		ts:add({"color", 0, 255, 128}, ("#ffa0ff#Predator: Acc +%d, APR +%d#LAST#"):format(predatorATK, predatorAPR), {"color", "WHITE"}, true)
	end

	-- stats
	--ts:add(("Stats: %d / %d / %d / %d / %d / %d"):format(self:getStr(), self:getDex(), self:getCon(), self:getMag(), self:getWil(), self:getCun()), true)

	-- ADD: status resist
	local immune_types = {"stun", "confusion", "poison", "disease", "blind", "silence", "disarm", "cut", "pin", "sleep", "fear", "knockback", "stone", "teleport", "instakill"}
	local immunes = {}
	for _, type in pairs(immune_types) do
		local v = self:attr(type.."_immune")
		if v and v > 0 then
			immunes[#immunes+1] = {type=type, v=v}
		end
	end
	if #immunes > 0 then
		-- table.sort(immunes, function(a, b) return a.v > b.v end)
		ts:add({"color","ANTIQUE_WHITE"}, "Immunity:")
		local first = true
		for _, t in pairs(immunes) do
			if not first then ts:add(",") end
			first = false
			local color = "#WHITE#"
			if t.type == "confusion" or t.type == "silence" or t.type == "sleep" or t.type == "fear" then
				color = "#YELLOW#"
			elseif t.type == "disease" then
				color = "#OLIVE_DRAB#"
			elseif t.type == "stone" or t.type == "teleport" then
				color = "#DARK_ORCHID#"
			end
			ts:add((" %s%s #WHITE#%d%%"):tformat(color, t.type:capitalize(), t.v*100))
		end
		ts:add(true)
	end

	-- damage resists
	-- MOD: color
	local resists = {}
	for t, v in pairs(self.resists) do
		local res = (t == "absolute") and v or self:combatGetResist(t)
		if res ~= 0 then
			resists[#resists+1] = { type = t, v = res }
		end
	end
	if #resists > 0 then
		ts:add({"color", "ANTIQUE_WHITE"}, "Resist:")
		addDamageList(ts, resists)
	end
	-- Terrasca?
	if self:attr("speed_resist") then
		local res = 100 - (util.bound(self.global_speed * self.movement_speed, (100-(self.speed_resist_cap or 70))/100, 1)) * 100
		if res > 0 then
			ts:add({"color", "LIGHT_GREEN"}, tostring(math.floor(res)).."%", " ", {"color", "SALMON"}, "from speed", {"color", "LAST"}, true)
		end
	end

	-- ADD: damage affinities
	local affinities = {}
	for t,v in pairs(self.damage_affinity) do
		local aff = self:combatGetAffinity(t)
		if aff ~= 0 then
			affinities[#affinities+1] = { type = t, v = aff }
		end
	end
	if #affinities > 0 then
		ts:add({"color", "ANTIQUE_WHITE"}, "Affinity:")
		addDamageList(ts, affinities)
	end

	-- ADD: crit shrug off / crit reduction
	ts:add("Crit.Shrug / Reduct: ", tostring(math.floor(self:attr("ignore_direct_crits") or 0)), '% / ', tostring(math.floor(self:combatCritReduction())) ,'%', true)

	-- armor / hardiness
	ts:add("Armour / Hardiness: ", tostring(math.floor(self:combatArmor())), ' / ', tostring(math.floor(self:combatArmorHardiness())), '%', true)

	-- acc, def
	ts:add("#FFD700#Accuracy#FFFFFF#: ", self:colorStats("combatAttack"), "  ")
	ts:add("#0080FF#Defense#FFFFFF#:  ", self:colorStats("combatDefense"), true)
	-- MAYBE: ranged defense
	-- if self:combatDefense(true) ~= self:combatDefenseRanged(true) then
	-- 	ts:add(" / ", self:colorStats("combatDefenseRanged"))
	-- end
	-- ts:add(true)
	-- power, save
	ts:add("#FFD700#P. power#FFFFFF#: ", self:colorStats("combatPhysicalpower"), "  ")
	ts:add("#0080FF#P. save#FFFFFF#:  ", self:colorStats("combatPhysicalResist"), true)
	ts:add("#FFD700#S. power#FFFFFF#: ", self:colorStats("combatSpellpower"), "  ")
	ts:add("#0080FF#S. save#FFFFFF#:  ", self:colorStats("combatSpellResist"), true)
	ts:add("#FFD700#M. power#FFFFFF#: ", self:colorStats("combatMindpower"), "  ")
	ts:add("#0080FF#M. save#FFFFFF#:  ", self:colorStats("combatMentalResist"), true)
	-- ADD: steam power
	if self:knowTalent(self.T_STEAM_POOL) then
		ts:add("#FFD700#Steam.power#FFFFFF#: ", self:colorStats("combatSteampower"), true)
	end
	ts:add({"color", "WHITE"})

	-- ADD: increased damage
	local damages = {}
	for t, v in pairs(self.inc_damage) do
		local dam = self:combatGetDamageIncrease(t)
		if dam ~= 0 then
			damages[#damages+1] = { type = t, v = dam }
		end
	end
	if #damages > 0 then
		ts:add({"color", "ANTIQUE_WHITE"}, "Damage:")
		addDamageList(ts, damages)
	end

	-- ADD: damage penetration
	local penetrations = {}
	for t, v in pairs(self.resists_pen) do
		local pen = self:combatGetResistPen(t)
		if pen ~= 0 then
			penetrations[#penetrations+1] = { type = t, v = pen }
		end
	end
	if #penetrations > 0 then
		ts:add({"color", "ANTIQUE_WHITE"}, "Penetration:")
		addDamageList(ts, penetrations)
	end

	-- ADD: Speed
	local gspeed = self.global_speed*100
	local mvspeed = self.movement_speed*100
	-- TODO: it seemed that weapon speed doesn't apply?
	local phspeed = self.combat_physspeed*100
	local spspeed = self.combat_spellspeed*100
	local mspeed = self.combat_mindspeed*100
	if gspeed ~= 100 or mvspeed ~= 100 or phspeed ~= 100 or spspeed ~= 100 or mspeed ~= 100 then
		ts:add({"color", "ANTIQUE_WHITE"}, "Speed:", {"color", "WHITE"})
		local count = 0
		if gspeed ~= 100 then
			ts:add((" %s%d%%#WHITE#"):tformat(colorPercent(gspeed, 100),gspeed))
			count = count+1
		end
		if mvspeed ~= 100 and mvspeed ~= gspeed then
			if count > 0 then ts:add(",") end
			ts:add((" Move %s%d%%#WHITE#"):tformat(colorPercent(mvspeed, 100), mvspeed))
			count = count+1
		end
		if phspeed == spspeed and phspeed == mspeed then
			if phspeed ~= 100 and phspeed ~= gspeed then
				if count > 0 then ts:add(",") end
				ts:add((" Combat %s%d%%#WHITE#"):tformat(colorPercent(phspeed, 100), phspeed))
				count = count+1
			end
		else
			if phspeed ~= 100 and phspeed ~= gspeed then
				if count > 0 then ts:add(",") end
				ts:add((" Atk %s%d%%#WHITE#"):tformat(colorPercent(phspeed, 100), phspeed))
				count = count+1
			end
			if spspeed ~= 100 and spspeed ~= gspeed then
				if count > 0 then ts:add(",") end
				ts:add((" Spell %s%d%%#WHITE#"):tformat(colorPercent(spspeed, 100), spspeed))
				count = count+1
			end
			if mspeed ~= 100 and mspeed ~= gspeed then
				if count > 0 then ts:add(",") end
				ts:add((" Mind %s%d%%#WHITE#"):tformat(colorPercent(mspeed, 100), mspeed))
				count = count+1
			end
		end
		ts:add(true)
	end

	-- ADD: crit rate
	ts:add(("Crit: Phys %d%%, Spel %d%%, Mind %d%%"):tformat(self:combatCrit(nil), self:combatSpellCrit(), self:combatMindCrit()))
	if self:knowTalent(self.T_STEAM_POOL) then
		ts:add((", Steam %d%%"):tformat(self:combatSteamCrit()))
	end
	ts:add(true)

	-- crit mult
	if (150 + (self.combat_critical_power or 0) ) > 150 then
		ts:add("Crit.Mult: ", ("%d%%"):format(150 + (self.combat_critical_power or 0) ), true )
	end

	-- weapon type: damage, apr, crit, range
	-- short name of weapon
	local inv = self:getInven("MAINHAND")
	if inv then
		for i, o in ipairs(inv) do
			local stats = self:getCombatStats("mainhand", self.INVEN_MAINHAND, i )
			addWeapon(ts, o, stats, "Main")
		end
	end
	inv = self:getInven("OFFHAND")
	if inv then
		for i, o in ipairs(inv) do
			local stats = self:getCombatStats("offhand", self.INVEN_OFFHAND, i)
			addWeapon(ts, o, stats, "Off ")
		end
	end
	inv = self:getInven("PSIONIC_FOCUS")
	if inv and self:attr("psi_focus_combat") then
		for i, o in ipairs(inv) do
			local stats = self:getCombatStats("psionic", self.INVEN_PSIONIC_FOCUS, i)
			addWeapon(ts, o, stats, "Psi ")
		end
	end
	inv = self:getInven("QUIVER")
	if inv then
		for i, o in ipairs(inv) do
			local tst = ("#LIGHT_BLUE#Ammo:#LAST#"..o:getShortName({force_id=true, do_color=true, no_add_name=true})):toTString()
			tst = tst:splitLines(game.tooltip.max-1, game.tooltip.font, 2)
			tst = tst:extractLines(true)[1]
			table.append(ts, tst)
			ts:add(true)
		end
	end
	-- TODO: no weapon slot mobs don't show unarmed dmg etc
	if self:isUnarmed() then
		inv = self:getInven("HANDS")
		if inv then
			-- Gloves merge to the Actor.combat table so we have to special case this to display the object but look at self.combat for the damage
			for i, o in ipairs(inv) do
				local stats = self:getCombatStats("barehand", self.INVEN_MAINHAND, i)
				addWeapon(ts, o, stats, "Unarmed")
			end
		else
			local stats = self:getCombatStats("barehand", self.INVEN_MAINHAND, i)
			addWeapon(ts, nil, stats, "Unarmed")
		end
	end

	-- melee retaliation
	ts:add({"color", "WHITE"})
	local retal = 0
	for k, v in pairs(self.on_melee_hit) do
		if type(v) == "number" then retal = retal + v
		elseif type(v) == "table" and type(v.dam) == "number" then retal = retal + v.dam
		end
	end
	if retal > 0 then ts:add("Melee Retaliation: ", {"color", "RED"}, tostring(math.floor(retal)), {"color", "WHITE"}, true ) end

	-- MOV: move flavor text to NPC.lua

	-- classes
	if self.descriptor and self.descriptor.classes then
		ts:add(_t"Class: ", table.concat(table.ts(self.descriptor.classes or {}, "birth descriptor name"), ","), true)
	end

	-- prodigies
	local ubers = {}
	for tid, lev in pairs(self.talents) do
		local t = self.talents_def[tid]
		if t and t.uber then
			ubers[#ubers+1] = t.name
		end
	end
	if #ubers > 0 then
		ts:add({"color", "YELLOW"},_t"Prodigy: ", table.concat(ubers, ", "), {"color", "WHITE"}, true)
	end

	-- custom?
	if self.custom_tooltip then
		local cts = self:custom_tooltip():toTString()
		if cts then
			ts:merge(cts)
			ts:add(true)
		end
	end

	-- sustain
	-- MOD: add dispel type (physical, mental or spell?)
	local first = true
	local susmental = tstring{}
	local susmagical = tstring{}
	for tid, act in pairs(self.sustain_talents) do
		if act then
			local t = self:getTalentFromId(tid)
			if t then
				if first then
					ts:add({"color", "ORANGE"}, "Sustained Talents: ",{"color", "WHITE"}, true)
					first = false
				end
				if t.is_mind then
					susmental:add("- ", {"color", "LIGHT_GREEN"}, t.name or "???", {"color", "YELLOW"}, " (m)", {"color", "WHITE"}, true)
				elseif t.is_spell then
					susmagical:add("- ", {"color", "LIGHT_GREEN"}, t.name or "???", {"color", "DARK_ORCHID"}, " (sp)", {"color", "WHITE"}, true)
				else
					ts:add("- ", {"color", "LIGHT_GREEN"}, t.name or "???", {"color", "WHITE"}, " (ph)", true)
				end
			end
		end
	end
	ts:merge(susmental)
	ts:merge(susmagical)

	-- status effects
	local first = true
	local effphysical_bad = tstring{}
	local effmental_bad = tstring{}
	local effmagical_bad = tstring{}
	local effother_bad = tstring{}
	local effphysical_good = tstring{}
	local effmental_good = tstring{}
	local effmagical_good = tstring{}
	local effother_good = tstring{}

	local desceffect = function(e, p, dur)
		local dur = e.decrease > 0 and dur or nil
		local charges = nil
		if e.charges then charges = e.charges and tostring(e.charges(self, p)) end

		if dur and charges then return ("%s(%d, %s)"):format(e.desc, dur, charges)
		elseif dur and not charges then return ("%s(%d)"):format(e.desc, dur)
		elseif not dur and charges then return ("%s(%s)"):format(e.desc, charges)
		else return e.desc end
	end

	for eff_id, p in pairs(self.tmp) do
		if first then
			first = false
			ts:add({"color", "ORANGE"}, "Temporary Status Effects: ",{"color", "WHITE"}, true)
		end
		local e = self.tempeffect_def[eff_id]
		local dur = p.dur + 1
		if e.status == "detrimental" then
			if e.type == "physical" then
				effphysical_bad:add("- ", {"color", "LIGHT_RED"}, desceffect(e, p, dur), {"color", "WHITE"}, " (ph)", true)
			elseif e.type == "magical" then
				if e.subtype and e.subtype.disease then
					-- change color that hard to see
					-- from DARK_GREEN
					effmagical_bad:add("- ", {"color", "OLIVE_DRAB"}, desceffect(e, p, dur), {"color", "DARK_ORCHID"}, " (sp)", {"color", "WHITE"}, true)
				else
					effmagical_bad:add("- ", {"color", "DARK_ORCHID"}, desceffect(e, p, dur), " (sp)", {"color", "WHITE"}, true)
				end
			elseif e.type == "mental" then
				effmental_bad:add("- ", {"color", "YELLOW"}, desceffect(e, p, dur), " (m)", {"color", "WHITE"}, true)
			elseif e.type == "other" then
				effother_bad:add("- ", {"color", "ORCHID"}, desceffect(e, p, dur), {"color", "WHITE"}, true)
			else
				ts:add("- ", {"color", "LIGHT_RED"}, desceffect(e, p, dur), {"color", "WHITE"}, true)
			end
		else
			if e.type == "physical" then
				effphysical_good:add("- ", {"color", "LIGHT_GREEN"}, desceffect(e, p, dur), {"color", "WHITE"}, " (ph)", true)
			elseif e.type == "mental" then
				effmental_good:add("- ", {"color", "LIGHT_GREEN"}, desceffect(e, p, dur), {"color", "YELLOW"}, " (m)", {"color", "WHITE"}, true)
			elseif e.type == "magical" then
				effmagical_good:add("- ", {"color", "LIGHT_GREEN"}, desceffect(e, p, dur), {"color", "DARK_ORCHID"}, " (sp)", {"color", "WHITE"}, true)
			else
				effother_bad:add("- ", {"color", "LIGHT_GREEN"}, desceffect(e, p, dur), {"color", "WHITE"}, true)
			end
		end
	end

	ts:merge(effphysical_bad)
	ts:merge(effmental_bad)
	ts:merge(effmagical_bad)
	ts:merge(effother_bad)
	ts:merge(effphysical_good)
	ts:merge(effmental_good)
	ts:merge(effmagical_good)
	ts:merge(effother_good)

	-- MOV: faction
	local factcolor, factstate, factlevel = "#ANTIQUE_WHITE#", "neutral", Faction:factionReaction(self.faction, game.player.faction)
	if factlevel < 0 then factcolor, factstate = "#LIGHT_RED#", "hostile"
	elseif factlevel > 0 then factcolor, factstate = "#LIGHT_GREEN#", "friendly"
	end
	if self.faction and Faction.factions[self.faction] then ts:add("Faction: ") ts:merge(factcolor:toTString()) ts:add(("%s (%s, %d)"):format(Faction.factions[self.faction].name, factstate, factlevel), {"color", "WHITE"}) end

	local pfactcolor, pfactstate, pfactlevel = "#ANTIQUE_WHITE#", "neutral", self:reactionToward(game.player)
	if pfactlevel < 0 then pfactcolor, pfactstate = "#LIGHT_RED#", "hostile"
	elseif pfactlevel > 0 then pfactcolor, pfactstate = "#LIGHT_GREEN#", "friendly"
	end
	if game.player ~= self then ts:add(true, "Personal reaction: ") ts:merge(pfactcolor:toTString()) ts:add(("%s, %d"):format(pfactstate, pfactlevel), {"color", "WHITE"}) end

	-- MOV: target
	if self ~= game.player then
		local target = self.ai_target.actor
		ts:add(true, _t"Target: ", target and target:getName() or _t"none")
		-- Give hints to stealthed/invisible players about where the NPC is looking (if they have LOS)
		if target == game.player and (game.player:attr("stealth") or game.player:attr("invisible")) and game.player:hasLOS(self.x, self.y) then
			local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
			local dx, dy = tx - self.ai_target.actor.x, ty - self.ai_target.actor.y
			local offset = engine.Map:compassDirection(dx, dy)
			ts:add(true)
			if offset then
				ts:add((" looking %s"):tformat(offset))
				if config.settings.cheat then ts:add((" (%+d, %+d)"):format(dx, dy)) end
			else
				ts:add(_t" looking at you.")
			end
		end
	end

	-- ADD: stealth, invisible
	local stealth = self:attr("stealth")
	local invisible = self:attr("invisible")
	if stealth or invisible then ts:add(true) end
	if stealth then
		stealth = stealth + (self:attr("inc_stealth") or 0)
		ts:add(("Stealth: %d"):tformat(stealth))
	end
	if invisible then
		if stealth then ts:add(", ") end
		ts:add(("Invisible: %d"):tformat(invisible))
	end

	-- ADD: see stealth / invisible
	if self == game.player or game.player:attr("stealth") or game.player:attr("invisible") or ctrl then
		ts:add(true, ("See Stealth / Invisible: %d / %d"):tformat(self:combatSeeStealth(), self:combatSeeInvisible()))
	end

	return ts
end

return _M
