--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Hodir", 603, 1644)
if not mod then return end
mod:RegisterEnableMob(32845)
mod.engageId = 1135
mod.respawnTime = 30

--------------------------------------------------------------------------------
-- Locals
--

local flashFreezed = mod:NewTargetList()
local lastCold = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.hardmode = "Hard mode"
	L.hardmode_desc = "Show timer for hard mode."
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		62039, -- Biting Cold
		{65133, "ICON"}, -- Storm Cloud
		61968, -- Flash Freeze
		63512, -- Frozen Blows
		"hardmode",
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "FlashFreezeCast", 61968)
	self:Log("SPELL_AURA_APPLIED", "FlashFreeze", 61969)
	self:Log("SPELL_AURA_APPLIED", "FrozenBlows", 63512)
	self:Log("SPELL_AURA_APPLIED", "StormCloud", 65133)
	self:Log("SPELL_AURA_REMOVED", "StormCloudRemoved", 65133)

	self:RegisterUnitEvent("UNIT_AURA", "BitingCold", "player")
end

function mod:OnEngage()
	lastCold = 0
	self:Bar(61968, 35) -- Flash Freeze
	self:Bar("hardmode", 150, L.hardmode, 27578) -- ability_warrior_battleshout / Battle Shout / icon 132333
	self:Berserk(480)
end

function mod:VerifyEnable(unit)
	return (UnitIsEnemy(unit, "player") and UnitHealth(unit) > 100) and true or false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:StormCloud(args)
	self:TargetMessage(args.spellId, args.destName, "Positive", "Info")
	self:TargetBar(args.spellId, 30, args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:StormCloudRemoved(args)
	self:StopBar(args.spellName, args.destName)
	self:PrimaryIcon(args.spellId)
end

function mod:FlashFreezeCast(args)
	self:Message(args.spellId, "Attention", "Long", CL.casting:format(args.spellName))
	self:CastBar(args.spellId, 9)
	self:Bar(args.spellId, 35)
	self:DelayedMessage(args.spellId, 30, "Attention", CL.custom_sec:format(args.spellName, 5))
end

function mod:FlashFreeze(args)
	if args.destGUID:find("Player", nil, true) then -- Applies to NPCs
		flashFreezed[#flashFreezed + 1] = args.destName
		if #flashFreezed == 1 then
			self:ScheduleTimer("TargetMessage", 0.3, 61968, flashFreezed, "Urgent", "Alert")
		end
	end
end

function mod:FrozenBlows(args)
	self:Message(args.spellId, "Important")
	self:Bar(args.spellId, 20)
end

do
	local cold = mod:SpellName(62039)
	function mod:BitingCold(unit)
		local _, _, _, stack = UnitDebuff(unit, cold)
		if stack and stack ~= lastCold then
			if stack > 1 then
				self:Message(62039, "Personal", "Alert", CL.you:format(CL.count:format(cold, stack)))
			end
			lastCold = stack
		end
	end
end

