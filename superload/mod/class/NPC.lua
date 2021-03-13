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

	-- MOV: move target to actor.lua
	-- killed by you
	local killed = game:getPlayer(true).all_kills and (game:getPlayer(true).all_kills[self.name] or 0) or 0
	str:add(true, ("Killed by you: %s"):tformat(killed))

	-- MOV: flavor text
	if self.desc then str:add(true, self.desc) end

	if config.settings.cheat then
		str:add(true, _t"UID: "..self.uid, true, self.image)
	end
	return str
end
