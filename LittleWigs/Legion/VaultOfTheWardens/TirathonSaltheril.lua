--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Tirathon Saltheril", 1493, 1467)
if not mod then return end
mod:RegisterEnableMob(95885, 99013, 98177) -- Tirathon, Drelanim
mod.engageId = 1815

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_trigger = "I will serve MY people, the exiled and the reviled."
	L.warmup_trigger2 = "I gave of my flesh, my soul; my people shun me as a freak."
end
--------------------------------------------------------------------------------
-- Locals
--

local FelMortarCount = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		191941, -- Darkstrikes
		191853, -- Furious Flames
		191823, -- Furious Blast
		190830, -- Hatred
		192504, -- Metamorphosis (Havoc)
		202740, -- Metamorphosis (Vengeance)
		191765, -- Swoop
		202913, -- Fel Mortar
	}, {
		[192504] = 192504 -- Metamorphosis
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Warmup")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")
	self:Log("SPELL_CAST_START", "DarkstrikesCast", 191941, 204151)
	self:Log("SPELL_AURA_APPLIED", "DarkstrikesApplied", 191941)
	self:Log("SPELL_AURA_APPLIED", "Vengeance", 202740)
	self:Log("SPELL_AURA_APPLIED", "Havoc", 192504)
	self:Log("SPELL_AURA_APPLIED", "FuriousFlamesApplied", 191853)
	self:Log("SPELL_CAST_START", "FuriousBlast", 191823)
	self:Log("SPELL_CAST_START", "FelMortar", 202913)
end

function mod:OnEngage()
	self:CDBar(191941, 5.2) -- Darkstrikes
	self:CDBar(202913, 13)
	self:CDBar(191765, 12.9)
	FelMortarCount = 0
end

function mod:VerifyEnable(_, mobId)
	if mobId == 99013 then -- Drelanim is a friendly NPC
		local _, _, completed = C_Scenario.GetCriteriaInfo(1)
		return not completed
	end
	return true
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Warmup(event, msg)
	if msg == L.warmup_trigger then
		self:UnregisterEvent(event)
		self:Bar("warmup", 10, CL.active, "achievement_dungeon_vaultofthewardens")
	elseif msg == L.warmup_trigger2 then
		self:Bar("warmup", 34, CL.active, "achievement_dungeon_vaultofthewardens")
	end
end

function mod:DarkstrikesCast(args)
	self:Message(191941, "Important", self:Tank() and "Alarm", CL.casting:format(args.spellName))
	self:CDBar(191941, 31)
end

function mod:DarkstrikesApplied(args)
	self:TargetMessage(args.spellId, args.destName, "Urgent")
	self:Bar(args.spellId, 10, CL.onboss:format(args.spellName))
end

function mod:FelMortar(args)
	self:Message(args.spellId, "Personal", "Alert")
	if FelMortarCount == 1 then
		self:CDBar(202913, 16)
	end
end

function mod:Havoc(args)
	self:Message(args.spellId, "Neutral", "Info")
	self:CDBar(191941, 24) -- Darkstrikes
	self:CDBar(190830, 14.5) -- Hatred
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, spellName, _, _, spellId)
	if spellId == 190830 then -- Hatred
		self:Message(spellId, "Attention", "Warning")
		self:Bar(spellId, 10, CL.cast:format(spellName))
		self:CDBar(191765, 17.5)
		self:CDBar(spellId, 30)
	elseif spellId == 191765 then
		self:Message(spellId, "Attention", "Warning")
	end
end

function mod:Vengeance(args)
	self:Message(args.spellId, "Neutral", "Info")
	self:CDBar(191941, 25)
	self:CDBar(202913, 15)
	FelMortarCount = 1
end

function mod:FuriousFlamesApplied(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "Personal", "Alert", CL.underyou:format(args.spellName))
	end
end

function mod:FuriousBlast(args)
	self:Message(args.spellId, "Urgent", "Alarm", CL.casting:format(args.spellName))
	self:CDBar(191823, 30)
end
