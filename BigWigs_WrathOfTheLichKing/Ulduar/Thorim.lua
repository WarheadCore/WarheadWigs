--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Thorim", 603, 1645)
if not mod then return end
mod:RegisterEnableMob(32865)
mod.engageId = 1141
mod.respawnTime = 32

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.phase2_trigger = "Interlopers! You mortals who dare to interfere with my sport will pay.... Wait--you..."
	L.phase3_trigger = "Impertinent whelps, you dare challenge me atop my pedestal? I will crush you myself!"

	L.hardmode = "Hard mode timer"
	L.hardmode_desc = "Show timer for when you have to reach Thorim in order to enter hard mode in phase 3."
	L.hardmode_warning = "Hard mode expires"

	L.barrier_message = "Barrier up!"

	L.charge_message = "Charged x%d!"
	L.charge_bar = "Charge %d"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		62042, -- Stormhammer
		62016, -- Charge Orb
		62331, -- Impale
		{62017, "FLASH"}, -- Lightning Shock
		62338, -- Runic Barrier
		{62526, "ICON", "SAY"}, -- Rune Detonation
		62942, -- Runic Fortification
		62279, -- Lightning Charge
		62130, -- Unbalancing Strike
		"proximity",
		"hardmode",
		"stages",
		"berserk",
	}, {
		[62042] = CL.stage:format(1),
		[62279] = CL.stage:format(2),
		hardmode = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Stormhammer", 62042)
	self:Log("SPELL_AURA_APPLIED", "LightningChargeApplied", 62279)
	self:Log("SPELL_AURA_APPLIED_DOSE", "LightningChargeApplied", 62279)
	self:Log("SPELL_CAST_SUCCESS", "UnbalancingStrikeCast", 62130)
	self:Log("SPELL_AURA_APPLIED", "UnbalancingStrike", 62130)
	self:Log("SPELL_CAST_SUCCESS", "RunicFortification", 62942)

	self:Log("SPELL_AURA_APPLIED", "RuneDetonation", 62526)
	self:Log("SPELL_AURA_REMOVED", "RuneDetonationRemoved", 62526)

	self:Log("SPELL_AURA_APPLIED", "ChargeOrb", 62016)
	self:Log("SPELL_AURA_APPLIED", "Impale", 62331, 62418)
	self:Log("SPELL_AURA_APPLIED", "RunicBarrier", 62338)
	self:Log("SPELL_DAMAGE", "LightningShockDamage", 62017)
	self:Log("SPELL_MISSED", "LightningShockDamage", 62017)

	self:Log("SPELL_AURA_APPLIED", "HardModeTimerBegins", 62507) -- Touch of Dominion, Sif spawns and begins the cast
	self:Log("SPELL_AURA_REMOVED", "HardModeTimerExpires", 62507) -- Touch of Dominion, Sif despawns
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

function mod:VerifyEnable(unit)
	return (UnitIsEnemy(unit, "player") and UnitHealth(unit) > 100) and true or false
end

function mod:OnEngage()
	self:Berserk(375)
	self:Bar("hardmode", 128, L.hardmode, 27578) -- ability_warrior_battleshout / Battle Shout / icon 132333
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:RunicBarrier(args)
	self:Message(args.spellId, "Urgent", "Alarm", L.barrier_message)
	self:Bar(args.spellId, 20)
end

function mod:LightningChargeApplied(args) -- Lightning Charge on Thorim
	local amount = args.amount or 1
	self:Message(args.spellId, "Attention", nil, L.charge_message:format(amount))
	self:Bar(args.spellId, 15, L.charge_bar:format(amount+1))
end

function mod:Stormhammer(args)
	self:TargetMessage(args.spellId, args.destName, "Urgent")
	self:Bar(args.spellId, 16)
end

function mod:UnbalancingStrike(args)
	self:TargetMessage(args.spellId, args.destName, "Attention")
	self:TargetBar(args.spellId, 15, args.destName)
end

function mod:UnbalancingStrikeCast(args)
	self:CDBar(args.spellId, 25)
end

function mod:RunicFortification(args)
	self:Message(args.spellId, "Attention")
end

function mod:ChargeOrb(args)
	self:Message(args.spellId, "Urgent")
	self:Bar(args.spellId, 15)
end

do
	local prev = 0
	function mod:LightningShockDamage(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 5 then
				prev = t
				self:Message(args.spellId, "Personal", "Info", CL.you:format(args.spellName))
				self:Flash(args.spellId)
			end
		end
	end
end

function mod:Impale(args)
	self:TargetMessage(62331, args.destName, "Important")
end

function mod:RuneDetonation(args)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, 40332) -- 40332 = "Bomb"
	end
	self:TargetMessage(args.spellId, args.destName, "Important")
	self:TargetBar(args.spellId, 4, args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:RuneDetonationRemoved(args)
	self:StopBar(args.spellName, args.destName)
	self:PrimaryIcon(args.spellId)
end

function mod:HardModeTimerBegins()
	-- Restart the bar for accuracy
	self:Bar("hardmode", 105, L.hardmode, 27578) -- ability_warrior_battleshout / Battle Shout / icon 132333
end

function mod:HardModeTimerExpires()
	if self:BarTimeLeft(L.hardmode) == 0 then
		self:Message("hardmode", "Neutral", nil, L.hardmode_warning, false)
	else
		self:Message("hardmode", "Neutral", nil, -17610, false) -- -17610 = "Hard Mode"
	end
end

function mod:StageTwo()
	-- Cancel scheduled berserk
	for k,v in next, self.scheduledMessages do
		self:CancelTimer(v)
		self.scheduledMessages[k] = nil
	end

	self:StopBar(L["hardmode"])
	self:Message("stages", "Attention", nil, CL.stage:format(2), false)
	self:OpenProximity("proximity", 5)
	self:Berserk(312, true) -- Berserk again with new timer and no engage message
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg == L.phase2_trigger then -- Stage 1
		if not self.isEngaged then
			self:Engage() -- Until boss frame shows for stage 1
		end
	elseif msg == L.phase3_trigger then -- Stage 2
		self:StageTwo()
	end
end
