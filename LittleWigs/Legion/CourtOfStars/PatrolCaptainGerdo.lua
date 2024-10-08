--TO DO
--Timers for ArcaneLockdown and SignalBeacon

--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Patrol Captain Gerdo", 1571, 1718)
if not mod then return end
mod:RegisterEnableMob(104215)
mod.engageId = 1868

--------------------------------------------------------------------------------
-- Initialization
--
local slashCount = 0

function mod:GetOptions()
	return {
		207261, -- Resonant Slash
		219488, -- Streetsweeper
		207278, -- Arcane Lockdown
		207806, -- Signal Beacon
		207815, -- Flask of the Solemn Night
		{215204, "SAY"}, -- Hinder
	}, {
		[207261] = self.displayName, -- Patrol Captain Gerdo
		[215204] = -13070, -- Vigilant Duskwatch
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "ResonantSlash", 207261)
	self:Log("SPELL_CAST_SUCCESS", "Streetsweeper", 219488)
	self:Log("SPELL_CAST_START", "ArcaneLockdown", 207278)
	self:Log("SPELL_CAST_START", "SignalBeacon", 207806)
	self:Log("SPELL_CAST_START", "Flask", 207815)
	-- Vigilant Duskwatch
	self:Log("SPELL_CAST_START", "Hinder", 215204)
	self:Log("SPELL_AURA_APPLIED", "HinderApplied", 215204)
end

function mod:OnEngage()
	slashCount = 0
	self:CDBar(219488, 11) -- Streetsweeper
	self:CDBar(207261, 7) -- Resonant Slash
	self:CDBar(207278, 15.5) -- Arcane Lockdown
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ResonantSlash(args)
	self:Message(args.spellId, "Urgent", "Alarm")
	self:Bar(args.spellId, slashCount % 2 == 0 and 16 or 12)
	slashCount = slashCount + 1
end

function mod:Streetsweeper(args)
	self:Message(args.spellId, "Important", "Info")
	self:CDBar(args.spellId, 7)
end

function mod:ArcaneLockdown(args)
	self:Message(args.spellId, "Attention", "Long", CL.incoming:format(args.spellName))
	self:CDBar(args.spellId, 28)
end

function mod:SignalBeacon(args)
	self:Message(args.spellId, "Attention", "Alert", CL.percent:format(75, args.spellName))
end

function mod:Flask(args)
	self:Message(args.spellId, "Attention", "Info", CL.percent:format(25, args.spellName))
end

-- Vigilant Duskwatch

do
	local prev = 0
	function mod:Hinder(args)
		local t = GetTime()
		if t - prev > 1 then
			prev = t
			self:Message(args.spellId, "Personal", "Warning", CL.casting:format(args.spellName))
		end
	end
end

function mod:HinderApplied(args)
	local _, class = UnitClass("player")
	if self:Dispeller("magic") or class == "WARLOCK" then
		self:TargetMessage(args.spellId, args.destName, "Important", "Bam", nil, nil, self:Dispeller("magic"))
	end
	if self:Me(args.destGUID) then
		self:Say(215204)
	end
end