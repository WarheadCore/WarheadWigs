
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Hyrja", 1477, 1486)
if not mod then return end
mod:RegisterEnableMob(95833)
mod.engageId = 1806 -- Fires when you attack the 2 mobs prior to the boss...

--------------------------------------------------------------------------------
-- Locals
--

local nextArcingBolt, nextExpelLight = 0, 0
local ShieldCount = 0
local list = mod:NewTargetList()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		200901, -- Eye of the Storm
		{191976, "ICON", "SAY"}, -- Arcing Bolt
		192307, -- Sanctify
		{192048, "ICON", "FLASH", "PROXIMITY", "SAY"}, -- Expel Light
		192018, -- Shield of Light
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Log("SPELL_CAST_START", "EyeOfTheStormOrSanctify", 200901, 192307) -- Eye of the Storm, Sanctify
	self:Log("SPELL_CAST_START", "ShieldOfLight", 192018)

	self:Log("SPELL_CAST_START", "ArcingBolt", 191976)
	self:Log("SPELL_CAST_SUCCESS", "ArcingBoltSuccess", 191976)

	self:Log("SPELL_AURA_APPLIED", "ExpelLight", 192048)
	self:Log("SPELL_AURA_REMOVED", "ExpelLightRemoved", 192048)

	self:Log("SPELL_AURA_APPLIED", "EmpowermentThunder", 192132) -- Mystic Empowerment: Thunder, grants Arcing Bolt
	self:Log("SPELL_AURA_REMOVED", "EmpowermentThunderRemoved", 192132)
	self:Log("SPELL_AURA_APPLIED", "EmpowermentHoly", 192133) -- Mystic Empowerment: Holy, grants Expel Light
	self:Log("SPELL_AURA_REMOVED", "EmpowermentHolyRemoved", 192133)

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")

	self:Death("Win", 95833)
end

function mod:OnEngage()
	local t = GetTime()
	ShieldCount = 0
	nextArcingBolt, nextExpelLight = t + 4.8, t + 4.5
	self:CDBar(192307, 9.5)
	self:CDBar(200901, 10)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, spellName, _, _, spellId)
	if spellId == 192307 and ShieldCount == 0 then
		self:CDBar(192018, 12.8)
		self:CDBar(192048, 18.5)
	elseif spellId == 192307 then
		self:CDBar(192018, 9.3)
		self:CDBar(192048, 14.3)
	end
end

function mod:ShieldOfLight(args)
	self:Message(args.spellId, "Important", "Alert")
	ShieldCount = ShieldCount + 1
end

function mod:EyeOfTheStormOrSanctify(args)
	local spellId = args.spellId
	if spellId == 200901 then
		self:CDBar(192307, 30)
	elseif spellId == 192307 then
		self:CDBar(200901, 30)
	end
	self:Message(args.spellId, "Urgent", "Long")
	self:CDBar(192018, 17) -- 192018 = Shield of Light. Yes, I checked both EotS and Sanctify.

	-- adjust Arcing Bolt's and Expel Light's CD bars
	local t = GetTime()
	local castTime = args.spellId == 200901 and 13 or 11.5
	if nextArcingBolt - t < castTime then
		nextArcingBolt = t + (castTime + 0.3)
		if self:BarTimeLeft(191976) > 0 then -- make sure there's a bar in the first place (EmpowermentThunderRemoved calls StopBar)
			self:CDBar(191976, castTime + 0.3)
		end
	end
	if nextExpelLight - t < castTime then
		nextExpelLight = t + (castTime + 3.8) -- doesn't cast it instantly after Sanctify / EotS
		if self:BarTimeLeft(192048) > 0 then -- make sure there's a bar in the first place (EmpowermentHolyRemoved calls StopBar)
			self:CDBar(192048, castTime + 3.8)
		end
	end
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(191976, name, "Attention", "Alarm", nil, nil, true)
		self:SecondaryIcon(191976, name)
		if self:Me(guid) then
			self:Say(191976)
		end
	end

	function mod:ArcingBolt(args)
		self:GetUnitTarget(printTarget, 0.4, args.sourceGUID)
	end

	function mod:ArcingBoltSuccess(args)
		self:SecondaryIcon(191976, nil)
		nextArcingBolt = GetTime() + 12
		self:CDBar(args.spellId, 13.3)
	end
end

function mod:ExpelLight(args)
	self:TargetMessage(args.spellId, args.destName, "Attention", "Alarm", nil, nil, true)
	self:TargetBar(args.spellId, 3, args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(192048, "Bam")
		self:OpenProximity(args.spellId, 8)
		self:Flash(args.spellId)
		local _, _, duration = self:UnitDebuff("player", args.spellId)
		self:SayCountdown(args.spellId, duration, 2, 3)
	else
		self:OpenProximity(args.spellId, 8, args.destName)
	end
	self:PrimaryIcon(args.spellId, args.destName)
	nextExpelLight = GetTime() + 20.7
	self:CDBar(args.spellId, 20.7)
end

function mod:ExpelLightRemoved(args)
	self:CloseProximity(args.spellId)
	self:PrimaryIcon(args.spellId)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "Positive", "Info", CL.removed:format(args.spellName))
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:EmpowermentThunder(args)
	local remaining = nextArcingBolt - GetTime()
	self:CDBar(191976, remaining > 1 and remaining or 2.6) -- Arcing Bolt
	if ShieldCount == 0 and self:BarTimeLeft(192307) > 0 and self:BarTimeLeft(200901) > 0 then
		self:StopBar(192307)
	end
end

function mod:EmpowermentThunderRemoved(args)
	self:StopBar(191976) -- Arcing Bolt
end

function mod:EmpowermentHoly(args)
	local remaining = nextExpelLight - GetTime()
	self:CDBar(192048, remaining > 1 and remaining or 2) -- Expel Light
	if ShieldCount == 0 and self:BarTimeLeft(192307) > 0 and self:BarTimeLeft(200901) > 0 then
		self:StopBar(200901)
	end
end

function mod:EmpowermentHolyRemoved(args)
	self:StopBar(192048) -- Expel Light
end
