
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Blade Lord Ta'yak", 1009, 744)
if not mod then return end
mod:RegisterEnableMob(62543)

--------------------------------------------------------------------------------
-- Locals
--

local phase = 1
local strikeCounter = 1
local usedMarks = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_yell = "On your guard, invaders. I, Ta'yak, Lord of Blades, will be your opponent."

	L.unseenstrike_soon = "Strike (%d) in ~5-10 sec!"
	L.assault_message = "Assault"
	L.side_swap = "Side Swap"

	L.custom_off_windstep = "Wind step marker"
	L.custom_off_windstep_desc = "To help healing assignments, mark the people who have wind step on them with {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}, requires promoted or leader."
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{125310, "FLASH"},
		122842, {-6346, "ICON", "SAY", "PROXIMITY"}, {123175, "PROXIMITY"}, "custom_off_windstep", {123474, "TANK_HEALER"}, -6350,
		"proximity", "berserk",
	}, {
		[125310] = "heroic",
		[122842] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "TayakCasts", "boss1")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "InstructorUnseenStrike")

	self:Log("SPELL_CAST_START", "BladeTempest", 125310)
	self:Log("SPELL_CAST_SUCCESS", "WindStep", 123175)
	self:Log("SPELL_AURA_APPLIED", "WindStepApplied", 123180)
	self:Log("SPELL_AURA_REMOVED", "WindStepRemoved", 123180)

	self:Log("SPELL_AURA_APPLIED", "Assault", 123474)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Assault", 123474)
	self:Log("SPELL_CAST_SUCCESS", "AssaultCast", 123474)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:RegisterMessage("BigWigs_BossComm")

	self:Death("Win", 62543)
end

function mod:OnEngage()
	if self:Heroic() then
		self:Bar(125310, 60) -- Blade Tempest
	end
	self:CDBar(122842, 9.8) -- Tempest Slash
	self:CDBar(123175, 20.5) -- Wind Step
	self:Bar(-6346, 30, CL["count"]:format(self:SpellName(122994), 1)) -- Unseen Strike
	self:Bar(123474, 15, L["assault_message"])
	self:OpenProximity(123175, 8)
	self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", nil, "boss1")
	self:Berserk(self:LFR() and 600 or 490)
	wipe(usedMarks)
	phase = 1
	strikeCounter = 1

	-- Engaging the boss means the Instructor is dead, so unregister this
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	-- wind step marker
	local function GetAvailableMark()
		for i=1, 6 do
			if not usedMarks[i] then
				return i
			end
		end
		return false
	end
	function mod:WindStepApplied(args)
		if not self.db.profile.custom_off_windstep then return end
		local mark = GetAvailableMark()
		if not mark then return end

		SetRaidTarget(args.destName, mark)
		usedMarks[mark] = args.destName
	end
	function mod:WindStepRemoved(args)
		if not self.db.profile.custom_off_windstep then return end
		for i=1, 6 do
			if usedMarks[i] == args.destName then
				usedMarks[i] = nil
				SetRaidTarget(args.destName, 0)
			end
		end
	end
end

function mod:BladeTempest(args)
	self:Message(args.spellId, "Important", "Alarm")
	self:Bar(args.spellId, 60)
	self:Flash(args.spellId)
end

function mod:WindStep(args)
	self:CDBar(args.spellId, 26.5)
end

do
	local timer = nil
	local function removeIcon(notBoss)
		mod:CloseProximity(-6346)
		if not notBoss then
			mod:OpenProximity(123175, 8) -- Re-open normal proximity
		end
		mod:PrimaryIcon(-6346)
		if timer then
			mod:CancelTimer(timer) -- Should never last this long, but no harm in it
			timer = nil
		end
	end
	local function warnStrike(notBoss)
		local strike = mod:SpellName(122994)
		local player = UnitDebuff("boss1target", strike) and "boss1target"
		if not player then -- Most of the time this won't run as boss1target works
			for unit in mod:IterateGroup() do
				player = UnitDebuff(unit, strike) and unit
				if player then break end
			end
		end
		if player then
			mod:CancelTimer(timer)
			timer = nil
			local name = mod:UnitName(player)
			if UnitIsUnit(player, "player") then
				mod:Say(-6346)
			else
				mod:OpenProximity(-6346, 5, name, true)
			end
			if not notBoss then
				mod:TargetMessage(-6346, name, "Urgent", "Alert", CL["count"]:format(strike, strikeCounter))
				strikeCounter = strikeCounter + 1
			else
				mod:TargetMessage(-6346, name, "Urgent", "Alert")
			end
			mod:TargetBar(-6346, 5.6, name)
			mod:PrimaryIcon(-6346, name)
		end
	end
	function mod:TayakCasts(_, spellName, _, _, spellId)
		if spellId == 122949 then --Unseen Strike
			self:CDBar(-6346, 53, CL["count"]:format(self:SpellName(122994), strikeCounter+1)) -- Unseen Strike, 53-60
			self:DelayedMessage(-6346, 48, "Attention", L["unseenstrike_soon"]:format(strikeCounter+1), false, "Alarm")
			if not timer then
				timer = self:ScheduleRepeatingTimer(warnStrike, 0.05) -- ~1s faster than boss emote
			end
			self:ScheduleTimer(removeIcon, 6.2)
		elseif spellId == 122839 then --Tempest Slash
			self:CDBar(122842, self:LFR() and 20.5 or 15.6)
		elseif spellId == 123814 then --Storm Unleashed (Phase 2)
			self:Message(-6350, "Positive", "Long", "20% - "..CL["phase"]:format(2))
			self:StopBar(125310) --Blade Tempest
			self:StopBar(L["assault_message"])
			self:StopBar(122839) --Tempest Slash
			self:StopBar(CL["count"]:format(self:SpellName(122994), strikeCounter)) -- Unseen Strike
			self:CancelDelayedMessage(L["unseenstrike_soon"]:format(strikeCounter))
			self:StopBar(123175) --Wind Step
			self:CloseProximity(123175)
		end
	end

	local casts = {}
	function mod:InstructorUnseenStrike(_, unit, _, _, spellCastGUID, spellId)
		if spellId == 122949 and not casts[spellCastGUID] and self:MobId(UnitGUID(unit)) == 64340 then
			self:Sync("Strike", spellCastGUID) -- Instructor Maltik
		end
	end
	function mod:BigWigs_BossComm(_, msg, spellCastGUID)
		if msg == "Strike" and not casts[spellCastGUID] then
			casts[spellCastGUID] = true
			if not timer then
				timer = self:ScheduleRepeatingTimer(warnStrike, 0.05, "notboss")
			end
			self:ScheduleTimer(removeIcon, 6.2, "notboss")
		end
	end
end

function mod:Assault(args)
	self:StackMessage(args.spellId, args.destName, args.amount, "Urgent", "Info", L["assault_message"])
end

function mod:AssaultCast(args)
	-- If a tank dies from an assault, it will never apply, and the CD bar won't show. Show it on cast instead.
	self:CDBar(args.spellId, 20.4, L["assault_message"])
end

function mod:UNIT_HEALTH_FREQUENT(unitId)
	local hp = UnitHealth(unitId) / UnitHealthMax(unitId) * 100
	if hp < 25 and phase == 1 then -- phase starts at 20
		self:Message(-6350, "Positive", "Long", CL["soon"]:format(CL["phase"]:format(2)))
		phase = 2
	elseif hp < 14 and phase == 2 then
		self:Message(-6350, "Positive", "Long", CL["soon"]:format(L["side_swap"]))
		self:UnregisterUnitEvent("UNIT_HEALTH_FREQUENT", unitId)
	end
end

