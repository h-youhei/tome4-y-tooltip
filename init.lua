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
addon_version = {1,1,1}
weight = 160
author = {'hukumitu.youhei@gmail.com'}
homepage = 'https://hkmtyh.com'
tags = {'tooltip','actors'}
description = [[Display more infomation in actor's tooltip. And add a hotkey to show actor's talents at cursor.

Showing Order: (+) is added, (*) is heavily modified
- Name (Range)
- Type / Subtype (gender)
- (*) Size (related talents helper) if size related talents are involved
- Level, Rank
- class
- (+) prodigy if the actor have
- invulnerability
- (*) Life [NegativeLife] +Regen (Healmod)
- Solipsism Psi if the actor have
- Iceblock if the actor freezed
- Manaburnable Resources if player is antimagic
- Summon Timer if the actor are summoned creature
- Vim Gain after kill if player has vim pool

- (+) Damage Modifiers
- (+) Damage Penetrations
- Damage Resists
- (+) Damage Affinities

- (+) Speeds
- (+) Crit Chance
- Crit Mult
- (+) Crit Shrug Off / Reduction
- (*) Weapon Damage, APR, Crit, Range, ego
- Armour (Hardiness)
- Melee Retaliation

- Predator Bonus if player know
- Accuracy, Defense
- Power, Save
- (+) Status Immunities

- Status Effects
- Sustains

- Faction
- Target
- Guess hiding player place if player is hidden
- (+) Stealth, Invisible helper if player is hidden
- (+) vs Stealth, Invisible

- Flavor Text
- Killed by you

Settings:
These can be hidden or shown in only normal or detailed (ctrl pressed) tooltips
- Type / Subtype (gender)
- Prodigies
- Manaburnable resources
- Vim Gain
- vs Stealth, Invisible
- Faction
- Flavor text
- Killed by you

These can be always shown or hidden regardless of the related talents involved
- Size
- Stealth, Invisible helper

These can set threshold
- Damage Modifiers
- Damage Penetration
- Damage Resists
- Damage Affinities
- Crit Mult
- Melee Retaliation

Intention:
Move flavor text to the bottom. Because some characters have very long flavor text that get in the way of seeing important infomation.

Range that is displayed on terrain tooltip in base game is also displayed next to actor's name. Because sometimes actor's tooltip is so long that need to wait scrolling to see the range.

Group relevant infomation.
And color labels to weak-group offense and defense.

Color DamageType. And change colors that hard to see.

Since name and level of talents is not enough information, add a way to open the actor's talents tab of character sheet quickly instead of displaying talents in the actor's tooltip.

Github: https://github.com/h-youhei/tome4-y-tooltip

Special Thanks:
- [https://te4.org/games/addons/tome/PlenumTooltipCustom Plenum Tooltip Custom Edit]
- [https://te4.org/games/addons/tome/NX_tooltipsPLUS Nexus improved tooltips]

Weight: 160

Superload:
- mod/class/Actor.lua:tooltip()
- mod/class/NPC.lua:tooltip()
- mod/class/Game.lua:setupCommands()]]
overload = false
superload = true
hooks = true
data = true
