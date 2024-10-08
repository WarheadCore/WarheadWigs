
--------------------------------------------------------------------------------
-- TODO List:
-- Timers kinda screw up after Mass Repentance Phase

--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Maiden of Virtue", 1651, 1825)
if not mod then return end
mod:RegisterEnableMob(113971)
mod.engageId = 1954

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.interrupted = "%s interrupted %s (%.1fs left)!"
end

--------------------------------------------------------------------------------
-- Locals
--

local sacredGroundOnMe = false
local sacredCount = 0
local shockCount = 0
local boltCount = 0
local holyWrathExplo = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		227817, -- Holy Bulwark
		227823, -- Holy Wrath
		227800, -- Holy Shock
		{227809, "SAY", "FLASH", "PROXIMITY"}, -- Holy Bolt
		227508, -- Mass Repentance
		{227789, "SAY", "FLASH"}, -- Sacred Ground
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_REMOVED", "HolyBulwarkRemoved", 227817)
	self:Log("SPELL_CAST_START", "HolyShock", 227800)
	self:Log("SPELL_CAST_START", "HolyWrath", 227823)
	self:Log("SPELL_CAST_START", "HolyBolt", 227809)
	self:Log("SPELL_CAST_SUCCESS", "HolyBoltSuccess", 227809)
	self:Log("SPELL_CAST_START", "MassRepentance", 227508)
	self:Log("SPELL_CAST_SUCCESS", "MassRepentanceSuccess", 227508)
	self:Log("SPELL_CAST_START", "SacredGround", 227789)
	self:Log("SPELL_AURA_APPLIED", "SacredGroundApplied", 227848)
	self:Log("SPELL_AURA_REMOVED", "SacredGroundRemoved", 227848)
	self:Log("SPELL_INTERRUPT", "Interrupt", "*")
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", nil, "boss1")
end

function mod:OnEngage()
	sacredGroundOnMe = false
	shockCount = 0
	boltCount = 1
	holyWrathExplo = 0
	sacredCount = 0
	self:Bar(227809, 9) -- Holy Bolt
	self:OpenProximity(227809, 6) -- Holy Bolt
	self:Bar(227789, 11) -- Sacred Ground
	self:Bar(227800, 16) -- Holy Shock
	self:Bar(227508, 50) -- Mass Repentance
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_STOP(_, _, _, spellId, spellName)
	if spellName == 227789 then
		self:CancelSayCountdown(227789)
	end
end

do
	local function printTarget(self, player, guid)
		self:TargetMessage(227789, player, "Important", "Alarm")
		if self:Me(guid) then
			self:SayCountdown(227789, 4, 2, 3)
			self:Say(227789)
			self:Flash(227789)
		end
	end

	function mod:SacredGround(args)
		self:CDBar(args.spellId, 23)
		self:GetBossTarget(printTarget, 0.3, args.sourceGUID)
		self:OpenProximity(227809, 6) -- Holy Bolt
	if sacredCount == 5 and boltCount == 5 then
		self:Bar(227809, 4) -- Holy Bolt
	elseif boltCount == 4 then
		self:Bar(227809, 9) -- Holy Bolt
		self:Bar(227800, 5) -- Holy Shock
	end
	sacredCount = sacredCount + 1
	end
end

function mod:HolyShock(args)
	if shockCount == 6 then
		self:StopBar(227789)
		self:StopBar(227800)
	elseif shockCount == 5 then
		self:CDBar(args.spellId, 13)
	elseif shockCount == 4 then
		self:CDBar(args.spellId, 13)
	elseif shockCount == 3 then
		self:CDBar(args.spellId, 10)
	elseif shockCount == 2 then
		self:CDBar(args.spellId, 10)
		self:StopBar(227789)
		self:StopBar(227800)
		self:StopBar(227809)
	else
		self:CDBar(args.spellId, 13)
	end

	shockCount = shockCount + 1

	if self:Interrupter(args.sourceGUID) then
		self:Message(args.spellId, "Attention", "Alarm", CL.incoming:format(args.spellName))
	end
end

function mod:HolyWrath(args)
	self:Message(args.spellId, "Important", "Alarm", CL.incoming:format(args.spellName))
	holyWrathExplo = GetTime() + 10
end

do
	local sacredGroundCheck = nil

	local function checkForSacredGround()
		if not sacredGroundOnMe then
			mod:Message(227789, "Personal", "Warning", CL.no:format(mod:SpellName(227848)))
			sacredGroundCheck = mod:ScheduleTimer(checkForSacredGround, 1.5)
		else
			mod:Message(227789, "Positive", nil, CL.you:format(mod:SpellName(227848)))
			sacredGroundCheck = nil
		end
	end

	function mod:MassRepentance(args)
		self:Message(args.spellId, "Attention", "Warning", CL.casting:format(args.spellName))
		self:Bar(args.spellId, 5, CL.cast:format(args.spellName))
		self:Bar(args.spellId, 51)
		boltCount = 4
		shockCount = 4
		sacredCount = 4
		self:StopBar(227809)
		self:StopBar(227789)
		self:StopBar(227800)
		checkForSacredGround()
	end

	function mod:SacredGroundApplied(args)
		if self:Me(args.destGUID) then
			sacredGroundOnMe = true
			if sacredGroundCheck then
				self:CancelTimer(sacredGroundCheck)
				checkForSacredGround() -- immediately check and give the positive message
			end
		end
	end

	function mod:SacredGroundRemoved(args)
		if self:Me(args.destGUID) then
			sacredGroundOnMe = false
		end
	end

	function mod:MassRepentanceSuccess(args)
		if sacredGroundCheck then
			self:CancelTimer(sacredGroundCheck)
			sacredGroundCheck = nil
		end
	end
end

function mod:HolyBulwarkRemoved(args)
	self:Message(227823, "Urgent", self:Interrupter(args.sourceGUID) and "Alert", CL.casting:format(self:SpellName(227823)))
end

do
	local function printTarget(self, player, guid)
		if self:Me(guid) then
			self:Say(227809)
		end
		self:TargetMessage(227809, player, "Important")
	end

	function mod:HolyBolt(args)
		self:GetBossTarget(printTarget, 0.3, args.sourceGUID)

		if boltCount == 6 then
			self:CDBar(args.spellId, 14)
		elseif boltCount == 5 and sacredCount == 5 then
			self:CDBar(args.spellId, 14)
			self:Bar(227789, 1)
		elseif boltCount == 5 then
			self:CDBar(args.spellId, 14)
		elseif boltCount == 4 then
			self:CDBar(args.spellId, 18)
		elseif boltCount == 3 then
			self:CDBar(args.spellId, 15)
		elseif boltCount == 2 then
			self:CDBar(args.spellId, 15)
		else
			self:CDBar(args.spellId, 14)
		end

		boltCount = boltCount + 1
	end

	function mod:HolyBoltSuccess(args)
		self:CloseProximity(args.spellId) -- we will later reopen it after a Sacred Ground cast, she never casts more than 1 Holy Bolt in between 2 Sacred Ground casts.
	end
end

do
	local prev = 0
	function mod:Interrupt(args)
		if args.extraSpellId == 227823 then
			self:StopBar(CL.cast:format(args.extraSpellName))
			self:Message(227508, "Positive", "Long", L.interrupted:format(self:ColorName(args.sourceName), args.extraSpellName, holyWrathExplo-GetTime()))
		end
	end
end