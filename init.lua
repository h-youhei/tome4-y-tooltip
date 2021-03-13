-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

long_name = "Y Tooltip"
short_name = "y-tooltip"
for_module = "tome"
version = {1,7,2}
addon_version = {1,0,0}
weight = 160
author = {'hukumitu.youhei@gmail.com'}
homepage = 'https://hkmtyh.com'
tags = {'tooltip','actors'}
description = [[Display more infomation in actor's tooltip.
- Status immunities
- Sustains' / Status effects' type (physical, magical or mental)
- Crit rate / multiplier
- Crit shrug off / reduction
- Speed
- Damage Affinity
- Damage Increase
- Damage Penetration
- Weapon'S APR, Crit rate, Range
- Stealth, Invisible info if appropriate

Move flavor text to the bottom. Because some characters have very long flavor text that get in the way of seeing important infomation.

Range that is displayed on terrain tooltip in base game is also displayed next to actor's name. Because sometimes actor's tooltip is so long that need to wait scrolling to see the range.

Color DamageType. And change colors that hard to see.

Showing Order:
- Name (Range)
- Type / Subtype (Size)
- Level, Rank
- Life [NegativeLife] +Regen (Healmod)
- Solipsism Psi
- Iceblock
- Manaburnable Resources if player is antimagic
- Summon Timer
- Vim Gain after kill if player has vim pool
- Predator Bonus
- Status Immunities
- Damage Resists
- Damage Affinities
- Crit Shrug Off / Reduction
- Armour / Hardiness
- Accuracy, Defense
- Power, Save
- Damage Increase
- Damage Penetration
- Speeds
- Crit Rate
- Crit Mult
- Weapon Damage, APR, Crit, Range
- Weapon's short name
- Melee Retaliation
- Classes
- Prodigies
- Sustains
- Status Effects
- Faction
- Target
- Guess hiding player place
- Stealth, Invisible
- See Stealth, Invisible
- Killed by you
- Flavor Text
]]
overload = false
superload = true
hooks = false
data = false
