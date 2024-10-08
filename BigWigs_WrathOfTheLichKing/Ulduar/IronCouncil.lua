--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Iron Council", 603, 1641)
if not mod then return end
mod:RegisterEnableMob(32867, 32927, 32857) -- Steelbreaker, Runemaster Molgeim, Stormcaller Brundir
mod.engageId = 1140
mod.respawnTime = 30

--------------------------------------------------------------------------------
-- Locals
--

local previous = nil
local deaths = 0
local tendrilscanner = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.summoning_message = "Elementals Incoming!"

	L.chased_other = "%s is being chased!"
	L.chased_you = "YOU are being chased!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		61869, -- Overload
		63483, -- Lightning Whirl
		{61887, "ICON", "FLASH"}, -- Lightning Tendrils
		61903, -- Fusion Punch
		{64637, "ICON", "FLASH", "PROXIMITY"}, -- Overwhelming Power
		62274, -- Shield of Runes
		61974, -- Rune of Power
		{62269, "FLASH"}, -- Rune of Death
		62273, -- Rune of Summoning
		"berserk",
		"stages",
	}, {
		[61869] = -17310, --Stormcaller Brundir
		[61903] = -17321, --Steelbreaker
		[62274] = -17315, --Runemaster Molgeim
		berserk = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "FusionPunch", 61903, 63493) -- Steelbreaker
	self:Log("SPELL_AURA_APPLIED", "OverwhelmingPower", 64637, 61888) -- Steelbreaker +2
	self:Log("SPELL_AURA_REMOVED", "OverwhelmingPowerRemoved", 64637, 61888)

	self:Log("SPELL_AURA_APPLIED", "ShieldOfRunes", 62274, 63489) -- Molgeim
	self:Log("SPELL_CAST_SUCCESS", "RuneOfPower", 61974) -- Molgeim
	self:Log("SPELL_CAST_SUCCESS", "RuneOfDeathSuccess", 62269, 63490) -- Molgeim +1
	self:Log("SPELL_AURA_APPLIED", "RuneOfDeath", 62269, 63490) -- Molgeim +1
	self:Log("SPELL_CAST_START", "RuneOfSummoning", 62273) -- Molgeim +2

	self:Log("SPELL_CAST_SUCCESS", "Overload", 61869, 63481) -- Brundir
	self:Log("SPELL_CAST_SUCCESS", "LightningWhirl", 63483, 61915) -- Brundir +1
	self:Log("SPELL_AURA_APPLIED", "LightningTendrils", 61887, 63486) -- Brundir +2
	self:Log("SPELL_AURA_REMOVED", "LightningTendrilsRemoved", 61887, 63486) -- Brundir +2

	self:Death("Deaths", 32867, 32927, 32857)
end

function mod:OnEngage()
	previous = nil
	deaths = 0
	self:Berserk(900)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FusionPunch(args)
	self:Message(61903, "Urgent")
end

function mod:OverwhelmingPower(args)
	if self:Me(args.destGUID) then
		self:OpenProximity(64637, 15)
		self:Flash(64637)
	end
	self:TargetMessage(64637, args.destName, "Personal", "Alert")
	self:TargetBar(64637, 35, args.destName)
	self:PrimaryIcon(64637, args.destName)
end

function mod:OverwhelmingPowerRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(64637)
	end
	self:StopBar(args.spellName, args.destName)
end

function mod:ShieldOfRunes(args)
	if self:MobId(args.destGUID) == 32927 then
		self:Message(62274, "Attention")
		self:Bar(62274, 30)
	end
end

function mod:RuneOfPower(args)
	self:Message(61974, "Positive")
	self:Bar(61974, 30)
end

function mod:RuneOfDeathSuccess(args)
	self:Bar(62269, 30)
end

function mod:RuneOfDeath(args)
	if self:Me(args.destGUID) then
		self:Message(62269, "Personal", "Alarm", CL.you:format(self:SpellName(62269)))
		self:Flash(62269)
	end
end

function mod:RuneOfSummoning(args)
	self:Message(args.spellId, "Attention", nil, L.summoning_message)
end

function mod:Overload(args)
	self:Message(61869, "Attention", "Long", CL.custom_sec:format(args.spellName, 6))
	self:Bar(61869, 6)
end

function mod:LightningWhirl(args)
	self:Message(63483, "Attention")
end

do
	local function targetCheck()
		local bossId = mod:GetUnitIdByGUID(32857)
		if not bossId then return end
		local target = UnitName(bossId .. "target")
		if target ~= previous then
			if target then
				if UnitIsUnit(target, "player") then
					mod:Message(61887, "Personal", "Alarm", L.chased_you)
					mod:Flash(61887)
				else
					mod:Message(61887, "Attention", nil, L.chased_other:format(target))
				end
				mod:PrimaryIcon(61887, target)
				previous = target
			else
				previous = nil
			end
		end
	end

	local last = nil
	function mod:LightningTendrils(args)
		local t = GetTime()
		if not last or (t > last + 2) then
			self:Message(61887, "Attention")
			self:Bar(61887, 25)
			if not tendrilscanner then
				tendrilscanner = self:ScheduleRepeatingTimer(targetCheck, 0.2)
			end
		end
	end
end

function mod:LightningTendrilsRemoved()
	self:CancelTimer(tendrilscanner)
	tendrilscanner = nil
	self:PrimaryIcon(61887)
end

function mod:Deaths(args)
	deaths = deaths + 1
	if deaths < 3 then
		self:Message("stages", "Positive", nil, CL.mob_killed:format(args.destName, deaths, 3), false)
	end
end

