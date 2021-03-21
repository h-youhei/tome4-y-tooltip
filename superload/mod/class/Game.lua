local _M = loadPrevious(...)

local Map = require "engine.Map"

local super_setupCommands = _M.setupCommands
function _M:setupCommands()
	super_setupCommands(self)

	self.key:addBinds {
		SHOW_CHARACTER_SHEET_TALENT_CURSOR = function()
			local mx, my = self.mouse.last_pos.x, self.mouse.last_pos.y
			local tmx, tmy = self.level.map:getMouseTile(mx, my)
			local a = self.level.map(tmx, tmy, Map.ACTOR)
			a = (config.settings.cheat or self.player:canSee(a)) and a or self.player
			self:registerDialog(require("mod.dialogs.CharacterSheet").new(a, "talents"))
		end,
	}
end
