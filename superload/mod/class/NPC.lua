-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
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

local _M = loadPrevious(...)

function _M:tooltip(x, y, seen_by)
	local str = mod.class.Actor.tooltip(self, x, y, seen_by)
	if not str then return end

	local function show(option)
		local conf = config.settings.tome["y_tooltip_"..option]
		local ctrl = core.key.modState("ctrl")
		return conf == 'both' or (conf == 'normal' and not ctrl) or (conf == 'ctrl' and ctrl)
	end

	-- MOV: move target to actor.lua

	-- MOV: flavor text
	if self.desc and show('flavor_text') then str:add(true, true, self.desc) end

	-- killed by you
	if show('killed_by_you') then
		local killed = game:getPlayer(true).all_kills and (game:getPlayer(true).all_kills[self.name] or 0) or 0
		str:add(true, ("Killed by you: %s"):tformat(killed))
	end

	if config.settings.cheat then
		str:add(true, _t"UID: "..self.uid, true, self.image)
	end
	return str
end
