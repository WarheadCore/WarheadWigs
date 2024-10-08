
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Illidan Stormrage", 564, 1590)
if not mod then return end
mod:RegisterEnableMob(22917, 23089, 22997) -- Illidan Stormrage, Akama, Flame of Azzinoth
mod.engageId = 609
mod.respawnTime = 10

--------------------------------------------------------------------------------
-- Locals
--

local playerList = mod:NewTargetList()
local burstCount = 0
local flamesDead = 0
local barrageCount = 0
local inDemonPhase = false
local isCaged = false
local timer1, timer2 = nil, nil
local fixateList = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.barrage_bar = "Barrage"
	L.warmup_trigger = "Akama. Your duplicity is hardly surprising. I should have slaughtered you and your malformed brethren long ago."
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		"stages",
		"berserk",

		--[[ Stage One: You Are Not Prepared ]]--
		41032, -- Shear
		{41917, "ICON", "SAY"}, -- Parasitic Shadowfiend
		40841, -- Flame Crash

		--[[ Stage Two: Flames of Azzinoth ]]--
		{40585, "ICON"}, -- Dark Barrage
		40018, -- Eye Blast
		39869, -- Uncaged Wrath
		40611, -- Blaze

		--[[ Stage Three: The Demon Within ]]--
		{40932, "PROXIMITY"}, -- Agonizing Flames
		41126, -- Flame Burst
		41117, -- Summon Shadow Demons
		40506, -- Demon Form

		--[[ Stage Four: The Long Hunt ]]--
		40683, -- Frenzy
		40695, -- Caged
	}, {
		[41032] = -15735, -- Stage One: You Are Not Prepared
		[40585] = -15740, -- Stage Two: Flames of Azzinoth
		[40932] = -15751, -- Stage Three: The Demon Within
		[40683] = -15757, -- Stage Four: The Long Hunt
	}
end

function mod:OnBossEnable()
	--[[ Stage One: You Are Not Prepared ]]--
	self:Log("SPELL_AURA_APPLIED", "Shear", 41032)
	self:Log("SPELL_AURA_APPLIED", "ParasiticShadowfiend", 41917)
	self:Log("SPELL_AURA_APPLIED", "ParasiticShadowfiendFailure", 41914)
	self:Log("SPELL_AURA_REMOVED", "ParasiticShadowfiendOver", 41917, 41914)

	--[[ Stage Two: Flames of Azzinoth ]]--
	self:Log("SPELL_CAST_START", "ThrowGlaive", 39849)
	self:Log("SPELL_AURA_APPLIED", "DarkBarrage", 40585)
	self:Log("SPELL_AURA_REMOVED", "DarkBarrageRemoved", 40585)
	self:Log("SPELL_AURA_APPLIED", "UncagedWrath", 39869)
	self:Log("SPELL_SUMMON", "EyeBlast", 40018)

	--[[ Stage Three: The Demon Within ]]--
	self:Death("FlameDeath", 22997) -- Flame of Azzinoth
	self:Log("SPELL_AURA_APPLIED", "AgonizingFlames", 40932)
	self:Log("SPELL_CAST_SUCCESS", "FlameBurst", 41126)
	self:Log("SPELL_CAST_START", "SummonShadowDemons", 41117)

	--[[ Stage Four: The Long Hunt ]]--
	self:Log("SPELL_CAST_SUCCESS", "ShadowPrison", 40647)
	self:Log("SPELL_AURA_REMOVED", "ShadowPrisonRemoved", 40647)
	self:Log("SPELL_CAST_SUCCESS", "Frenzy", 40683)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")
	self:RegisterUnitEvent("UNIT_AURA", nil, "boss1")

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_DAMAGE", "Damage", 40841, 40611, 40018, 40030) -- Flame Crash, Blaze, Eye Blast, Demon Fire (Eye Blast)
	self:Log("SPELL_MISSED", "Damage", 40841, 40611, 40018, 40030) -- Flame Crash, Blaze, Eye Blast, Demon Fire (Eye Blast)
end

function mod:OnEngage()
	timer1, timer2 = nil, nil
	burstCount = 0
	flamesDead = 0
	barrageCount = 0
	inDemonPhase = false
	isCaged = false
	wipe(playerList)
	wipe(fixateList)

	self:Berserk(1500)
	self:RegisterTargetEvents("CheckForFixate")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CheckForFixate(_, unit, guid)
	local mobId = self:MobId(guid)
	if mobId == 23498 and not fixateList[guid] and self:Me(UnitGUID(unit.."target")) then -- Parasitic Shadowfiend
		fixateList[guid] = true
		self:Say(41917, 41951) -- 41951 = "Fixate"
		self:Message(41917, "Personal", "Long", CL.you:format(self:SpellName(41951)), 41951)
	end
end

--[[ Stage One: You Are Not Prepared ]]--
function mod:Shear(args)
	self:TargetMessage(args.spellId, args.destName, "Important", "Alert")
	self:TargetBar(args.spellId, 7, args.destName)
end

function mod:ParasiticShadowfiend(args)
	self:TargetMessage(args.spellId, args.destName, "Attention", "Long")
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetBar(args.spellId, 10, args.destName, 36469, args.spellId) -- 36469 = "Parasite"
	if self:Me(args.destGUID) then
		self:Say(args.spellId, 36469) -- 36469 = "Parasite"
	end
end

function mod:ParasiticShadowfiendFailure(args) -- The parasite reached someone new before it was killed
	self:TargetMessage(41917, args.destName, "Attention")
	self:TargetBar(41917, 10, args.destName, 36469, 41917) -- 36469 = "Parasite"
	if self:Me(args.destGUID) then
		self:Say(41917, 36469) -- 36469 = "Parasite"
	end
end

function mod:ParasiticShadowfiendOver(args)
	self:StopBar(args.spellName, args.destName)
end

--[[ Stage Two: Flames of Azzinoth ]]--
function mod:ThrowGlaive() -- Stage 2
	flamesDead = 0

	self:PrimaryIcon(41917) -- Parasitic Shadowfiend
	self:CDBar(40585, 95) -- Dark Barrage
	self:Message("stages", "Neutral", nil, CL.stage:format(2), false)
end

function mod:DarkBarrage(args)
	self:TargetMessage(args.spellId, args.destName, "Important", "Alert")
	self:PrimaryIcon(args.spellId, args.destName)
	barrageCount = barrageCount + 1
	self:CDBar(args.spellId, 50) -- Varies between 50 and 70 depending on Eye Blast
	self:TargetBar(args.spellId, 10, args.destName, L.barrage_bar)
end

function mod:DarkBarrageRemoved(args)
	self:PrimaryIcon(args.spellId)
	self:StopBar(L.barrage_bar, args.destName)
end

function mod:UncagedWrath(args)
	self:Message(args.spellId, "Urgent", "Warning")
end

do
	local prev = 0
	function mod:EyeBlast(args)
		local t = GetTime()
		if t-prev > 2 then
			self:Message(args.spellId, "Attention", "Info", args.spellName, 224284) -- XXX temp until it has an icon
		end
		prev = t -- Continually spams every 1s during the cast
	end
end

--[[ Stage Three: The Demon Within ]]--
function mod:FlameDeath() -- Stage 3
	flamesDead = flamesDead + 1
	if flamesDead == 2 then
		self:StopBar(40585) -- Dark Barrage
		self:Message("stages", "Neutral", "Alarm", CL.stage:format(3), false)
		self:Bar(40506, 75) -- Demon Form
		self:OpenProximity(40932, 5) -- Agonizing Flames
	end
end

function mod:AgonizingFlames(args)
	playerList[#playerList+1] = args.destName
	if #playerList == 1 then
		self:ScheduleTimer("TargetMessage", 0.3, args.spellId, playerList, "Important", "Alert")
	end
end

function mod:FlameBurst(args)
	burstCount = burstCount + 1
	self:Message(args.spellId, "Important", "Alert")
	if burstCount < 3 then -- He'll only do three times before transforming again
		self:Bar(args.spellId, 20)
	end
end

function mod:SummonShadowDemons(args)
	self:Message(args.spellId, "Important", "Alert")
end

--[[ Stage Four: The Long Hunt ]]--
function mod:ShadowPrison(args) -- Pre Stage 4 Intermission
	self:Message("stages", "Neutral", nil, CL.intermission, false)
	self:Bar("stages", 30, CL.intermission, args.spellId)
end

function mod:ShadowPrisonRemoved(args) -- Stage 4
	if self:MobId(args.destGUID) == 23089 then -- When debuff drops from Akama (downstairs)
		self:Message("stages", "Neutral", nil, CL.stage:format(4), false)

		self:Bar(40683, 45) -- Frenzy
		self:Bar(40506, 60) -- Demon Form
	end
end

function mod:Frenzy(args)
	self:Message(args.spellId, "Urgent", "Long")
	--self:Bar(args.spellId, ??) -- Frenzy
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, spellName, _, _, spellId)
	if spellId == 40693 then -- Cage Trap
		self:Message(40695, "Important", "Info", CL.spawned:format(spellName), 199341) -- 199341: ability_hunter_traplauncher / icon 461122
	end
end

function mod:UNIT_AURA(unit)
	if UnitBuff(unit, self:SpellName(40506)) then -- Demon Form
		if not inDemonPhase then
			inDemonPhase = true
			burstCount = 0
			self:Bar(41117, 25) -- Summon Shadow Demons
			self:Bar(41126, 15) -- Flame Burst
			self:Message(40506, "Important", "Alarm") -- Demon Form
			local demonFormOver = CL.over:format(self:SpellName(40506))
			self:Bar(40506, 60, demonFormOver)
			timer1 = self:ScheduleTimer("Message", 60, 40506, "Positive", nil, demonFormOver) -- Demon Form
			timer2 = self:ScheduleTimer("Bar", 60, 40506, 60) -- Demon Form
		end
	elseif inDemonPhase then
		inDemonPhase = false
		self:CancelTimer(timer1)
		self:CancelTimer(timer2)
		timer1, timer2 = nil, nil
		self:StopBar(CL.over:format(self:SpellName(40506))) -- Demon Form
		self:StopBar(41117) -- Summon Shadow Demons
		self:StopBar(41126) -- Flame Burst
	end

	if UnitDebuff(unit, self:SpellName(40695)) then -- Caged
		if not isCaged then
			isCaged = true
			self:Message(40695, "Positive", "Warning")
			self:Bar(40695, 15)
		end
	elseif isCaged then
		isCaged = false
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg == L.warmup_trigger then
		self:Bar("warmup", 41.5, CL.active, "achievement_boss_illidan")
	end
end

do
	local prev = 0
	function mod:Damage(args)
		if self:Me(args.destGUID) and GetTime()-prev > 1.5 then
			prev = GetTime()
			self:Message(args.spellId == 40030 and 40018 or args.spellId, "Personal", "Alert", CL.underyou:format(args.spellId == 40030 and self:SpellName(40018) or args.spellName))
		end
	end
end
