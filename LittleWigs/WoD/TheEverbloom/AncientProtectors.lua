
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ancient Protectors", 1279, 1207)
if not mod then return end
mod:RegisterEnableMob(83894, 83892, 83893) -- Dulhu, Life Warden Gola, Earthshaper Telu
mod.engageId = 1757
mod.respawnTime = 30

--------------------------------------------------------------------------------
-- Locals
--

local lifeWardenGolaDefeated = false
local earthshaperTeluDefeated = false
local dulhuDefeated = false
local revitalizeCount = 1
local toxicBloomCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L[83892] = "|cFF00CCFFGola|r"
	L[83893] = "|cFF00CC00Telu|r"

	L.custom_on_automark = "Автоматическая маркировка боссов"
	L.custom_on_automark_desc = "Автоматически маркировать Гола {rt8} и Телу {rt7}, необходимо иметь на это разрешение."
	L.custom_on_automark_icon = 8
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return
	{
		-- Life Warden Gola
		{ 168082, "DISPEL" }, -- Revitalize
		427498, -- Torrential Fury

		-- Earthshaper Telu
		427459, -- Toxic Bloom
		427509, -- Terrestrial Fury

		-- Dulhu
		427510, -- Noxious Charge
		427513, -- Noxious Discharge

		"custom_on_automark",
	},
	{
		[168082] = "Страж Жизни Гола", -- Life Warden Gola
		[427459] = "Демиург Телу", -- Earthshaper Telu
		[427510] = "Дулгу", -- Dulhu
	}
end

function mod:OnBossEnable()
	-- Life Warden Gola
	self:Log("SPELL_CAST_START", "Revitalize", 168082)
	self:Log("SPELL_AURA_APPLIED", "RevitalizeApplied", 168082)
	self:Log("SPELL_CAST_START", "TorrentialFury", 427498)
	self:Death("LifeWardenGolaDeath", 83892)

	-- Earthshaper Telu
	self:Log("SPELL_CAST_START", "ToxicBloom", 427459)
	self:Log("SPELL_CAST_START", "TerrestrialFury", 427509)
	self:Death("EarthshaperTeluDeath", 83893)

	-- Dulhu
	self:Log("SPELL_AURA_APPLIED", "NoxiousCharge", 427510)
	self:Log("SPELL_PERIODIC_DAMAGE", "NoxiousDischargeDamage", 427513) -- no alert on APPLIED, doesn't damage right away
	self:Log("SPELL_PERIODIC_MISSED", "NoxiousDischargeDamage", 427513)
	self:Death("DulhuDeath", 83894)
end

function mod:OnEngage()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

	lifeWardenGolaDefeated = false
	earthshaperTeluDefeated = false
	dulhuDefeated = false
	revitalizeCount = 1
	toxicBloomCount = 1

	self:CDBar(427498, 1.0) -- Torrential Fury
	self:CDBar(427459, 7.1) -- Toxic Bloom
	self:CDBar(427510, 12.1) -- Noxious Charge
	self:CDBar(427509, 26.5) -- Terrestrial Fury
	self:CDBar(168082, 31.5) -- Revitalize
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	if self:GetOption("custom_on_automark") then
		for i = 1, 3 do
			local unit = ("boss%d"):format(i)
			local id = self:MobId(UnitGUID(unit))

			if id == 83892 and not lifeWardenGolaDefeated then
				if not IsInGroup() then SetRaidTarget(unit, 0) end -- setting the same icon twice while not in a group removes it
				SetRaidTarget(unit, 8)
			elseif id == 83893 then
				if not IsInGroup() then SetRaidTarget(unit, 0) end
				SetRaidTarget(unit, lifeWardenGolaDefeated and 8 or 7)
			end
		end
	end
end

-- Life Warden Gola
function mod:Revitalize(args)
	local raidIcon = CombatLog_String_GetIcon(args.sourceRaidFlags)
	self:Message(args.spellId, "Urgent", "Warning", CL.other:format(raidIcon.. L[83892], CL.casting:format(self:SpellName(31730)))) -- 31730 = "Heal"

	self:PlaySound(args.spellId, "warning")
	revitalizeCount = revitalizeCount + 1

	if earthshaperTeluDefeated or revitalizeCount % 2 == 0 then
		self:CDBar(args.spellId, 17.0)
	else
		-- will be delayed by Torrential Fury
		self:CDBar(args.spellId, 31.6)
	end
end

function mod:RevitalizeApplied(args)
	if self:Dispeller("magic", true, args.spellId) then
		self:Message(args.spellId, "yellow", "Alarm", CL.on:format(args.spellName, args.destName))
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:TorrentialFury(args)
	revitalizeCount = 1

	self:Message(args.spellId, "cyan")
	self:PlaySound(args.spellId, "long")

	if not earthshaperTeluDefeated then
		-- this will not be cast again if Earthshaper Telu has been defeated
		self:CDBar(args.spellId, 52.1)
	end

	if not earthshaperTeluDefeated and not dulhuDefeated then
		-- this will not be cast as usual if either of the other two bosses have been defeated
		self:CDBar(168082, 31) -- Revitalize
	end
end

function mod:LifeWardenGolaDeath()
	lifeWardenGolaDefeated = true

	self:StopBar(168082) -- Revitalize
	self:StopBar(427498) -- Torrential Fury
	-- Life Warden Gola dying stops Earthshaper Telu from casting Terrestrial Fury
	self:StopBar(427509) -- Terrestrial Fury
	self:INSTANCE_ENCOUNTER_ENGAGE_UNIT() -- no IEEU events on deaths
end

-- Earthshaper Telu
function mod:ToxicBloom(args)
	self:Message(args.spellId, "yellow", nil, CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "warning")

	toxicBloomCount = toxicBloomCount + 1

	if lifeWardenGolaDefeated or toxicBloomCount % 2 == 0 then
		self:CDBar(args.spellId, 17.0)
	else
		-- will be delayed by Terrestrial Fury
		self:CDBar(args.spellId, 31.6)
	end
end

function mod:TerrestrialFury(args)
	toxicBloomCount = 1

	self:Message(args.spellId, "cyan")
	self:PlaySound(args.spellId, "long")

	if not lifeWardenGolaDefeated then
		-- this will not be cast again if Life Warden Gola has been defeated
		self:CDBar(args.spellId, 52.1)
	end

	self:CDBar(427459, 31) -- Toxic Bloom
end

function mod:EarthshaperTeluDeath()
	earthshaperTeluDefeated = true

	self:StopBar(427459) -- Toxic Bloom
	self:StopBar(427509) -- Terrestrial Fury
	-- Earthshaper Telu dying stops Life Warden Gola from casting Torrential Fury and Revitalize
	self:StopBar(427498) -- Torrential Fury
	self:StopBar(168082) -- Revitalize
end

-- Dulhu
function mod:NoxiousCharge(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alert")
	self:CastBar(args.spellId, 4)
	self:CDBar(args.spellId, 17.0)
end

do
	local prev = 0

	function mod:NoxiousDischargeDamage(args)
		local t = GetTime()
		-- don't alert for tanks, this spawns instantly under them after Noxious Charge,
		-- while other roles have the projectile's travel time to move away.
		if t - prev > 1.5 and not self:Tank() and self:Me(args.destGUID) then
			prev = t
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou", nil, args.destName)
		end
	end
end

function mod:DulhuDeath()
	dulhuDefeated = true

	self:StopBar(CL.cast:format(self:SpellName(427510))) -- Noxious Charge
	self:StopBar(427510) -- Noxious Charge
	-- Dulhu dying stops Life Warden Gola from casting Revitalize
	self:StopBar(168082) -- Revitalize
end
