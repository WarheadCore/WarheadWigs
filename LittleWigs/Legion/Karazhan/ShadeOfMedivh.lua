
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Shade of Medivh", 1651, 1817)
if not mod then return end
mod:RegisterEnableMob(114350)
mod.engageId = 1965

--------------------------------------------------------------------------------
-- Locals
--

local frostbiteTarget = nil
local addsKilled = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.focused_power = -14036
	L.focused_power_icon = "ability_mage_greaterinvisibility"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		{227592, "SAY"}, -- Frostbite
		{227615, "SAY"}, -- Inferno Bolt
		227628, -- Piercing Missiles
		"focused_power",
		228334, -- Guardian's Image
		{228269, "SAY"}, -- Flame Wreath
		227779, -- Ceaseless Winter
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_POWER", nil, "boss1")
	self:Log("SPELL_CAST_START", "Frostbite", 227592)
	self:Log("SPELL_AURA_APPLIED", "FrostbiteApplied", 227592)
	self:Log("SPELL_AURA_REMOVED", "FrostbiteRemoved", 227592)
	self:Log("SPELL_CAST_START", "InfernoBolt", 227615)
	self:Log("SPELL_CAST_SUCCESS", "PiercingMissiles", 227628)
	self:Log("SPELL_CAST_START", "GuardiansImage", 228334)
	self:Log("SPELL_CAST_START", "FlameWreathStart", 228269)
	self:Log("SPELL_AURA_APPLIED", "FlameWreathApplied", 228261)
	self:Log("SPELL_CAST_START", "CeaselessWinter", 227779)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CeaselessWinterApplied", 227806)
	self:Death("ImageDeath", 114675)
end

function mod:OnEngage()
	addsKilled = 1 -- this variable is being reset at SPELL_CAST_START of Guardian's Image, comparing against it in UNIT_POWER to avoid introducing a new variable
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_POWER(unit)
	local nextSpecial = 30 * (1 - UnitPower(unit) / UnitPowerMax(unit))
	if nextSpecial > 0 and addsKilled ~= 0 then -- doesn't work like that while Guardian's Image is active
		local spellName = self:SpellName(L.focused_power)
		if math.abs(nextSpecial - self:BarTimeLeft(spellName)) > 1 then
			self:Bar("focused_power", nextSpecial, spellName, L.focused_power_icon)
		end
	end
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(227592, name, "Urgent", self:Interrupter() and "Alarm")
	end
	function mod:Frostbite(args)
		self:GetUnitTarget(printTarget, 1, args.sourceGUID)
	end
end

function mod:FrostbiteApplied(args)
	self:TargetMessage(args.spellId, args.destName, "Urgent", "Warning", nil, nil, true)
	frostbiteTarget = args.destName
	if self:Me(args.destGUID) then
		self:Say(args.spellId)
	end
end

function mod:FrostbiteRemoved(args)
	frostbiteTarget = nil
end

do
	local prev = 0
	local function printTarget(self, name, guid)
		local t = GetTime()
		if self:Me(guid) then
			local text = CL.you:format(self:SpellName(227615)) .. (frostbiteTarget and " - " .. CL.on:format(self:SpellName(227592), self:ColorName(frostbiteTarget)) or "")
			self:Message(227615, "Urgent", "Alert", text)
		elseif t-prev > 0.5 then
			prev = t
			self:TargetMessage(227615, name, "Important", "None")
		end
	end
	function mod:InfernoBolt(args)
		self:GetUnitTarget(printTarget, 1, args.sourceGUID)
	end
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(227628, name, "Attention", "none")
	end
	function mod:PiercingMissiles(args)
		self:GetUnitTarget(printTarget, 1, args.sourceGUID)
	end
end

function mod:GuardiansImage(args)
	self:Message(args.spellId, "Attention", "Long")
	addsKilled = 0
end

function mod:ImageDeath(args)
	addsKilled = addsKilled + 1
	self:Message("stages", "Neutral", addsKilled == 3 and "Long", CL.mob_killed:format(args.destName, addsKilled, 3), false)
end

function mod:FlameWreathStart(args)
	self:Message(args.spellId, "Attention", "Long", CL.incoming:format(args.spellName))
end

do
	local list = mod:NewTargetList()
	function mod:FlameWreathApplied(args)
		list[#list+1] = args.destName
		if #list == 1 then
			self:ScheduleTimer("TargetMessage", 0.2, 228269, list, "Important", "Warning", nil, nil, true)
			self:Bar(228269, 20)
		end
		if self:Me(args.destGUID) then
			self:Say(228269)
		end
	end
end

function mod:CeaselessWinter(args)
	self:Message(args.spellId, "Attention", "Long")
	self:Bar(args.spellId, 20)
end

function mod:CeaselessWinterApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 2 == 0 then
			self:StackMessage(227779, args.destName, amount, "Personal", "Warning")
		end
	end
end
