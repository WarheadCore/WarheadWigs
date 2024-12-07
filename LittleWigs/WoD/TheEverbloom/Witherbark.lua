
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Witherbark", 1279, 1214)
if not mod then return end
mod:RegisterEnableMob(81522)
mod.engageId = 1746
mod.respawnTime = 20

--------------------------------------------------------------------------------
-- Locals
--

local energy = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.energyStatus = "A Globule reached Witherbark: %d%% energy"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		164275, -- Brittle Bark
		164438, -- Energize
		164357, -- Parched Gasp
		{ 164294, "ME_ONLY" }, -- Unchecked Growth
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "BrittleBark", 164275)
	self:Log("SPELL_AURA_REMOVED", "BrittleBarkOver", 164275)
	self:Log("SPELL_CAST_SUCCESS", "Energize", 164438)
	self:Log("SPELL_CAST_START", "ParchedGasp", 164357)
	self:Log("SPELL_AURA_APPLIED", "UncheckedGrowth", 164294)
	self:Log("SPELL_CAST_SUCCESS", "UncheckedGrowthSpawned", 181113) -- Encounter Spawn

	self:Log("SPELL_AURA_APPLIED", "UncheckedGrowthApplied", 164302)
	self:Log("SPELL_PERIODIC_DAMAGE", "UncheckedGrowthDamage", 164294)
	self:Log("SPELL_PERIODIC_MISSED", "UncheckedGrowthDamage", 164294)
end

function mod:OnEngage()
	energy = 0
	self:CDBar(164294, 5.8) -- Unchecked Growth
	self:CDBar(164357, 9.7) -- Parched Gasp
	-- cast at 0 energy, 39s energy loss + delay
	self:CDBar(164275, 39.2) -- Brittle Bark
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UncheckedGrowth(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "Personal", "Alarm", CL.you:format(args.spellName))
	end
end

function mod:BrittleBark(args)
	energy = 0
	self:Message(args.spellId, "Attention", "Info", ("%s - %s"):format(args.spellName, CL.incoming:format(self:SpellName(-10100)))) -- 10100 = Aqueous Globules
	self:StopBar(164357) -- Parched Gasp
	self:StopBar(args.spellId)
end

function mod:BrittleBarkOver(args)
	self:Message(args.spellId, "Attention", "Info", CL.over:format(args.spellName))
	self:Bar(args.spellId, 40)
	self:CDBar(164357, 4) -- Parched Gasp
end

function mod:Energize()
	if self.isEngaged then -- This happens when killing the trash, we only want it during the encounter.
		energy = energy + 25

		if energy < 101 then
			self:Message(164275, "Neutral", nil, L.energyStatus:format(energy), "spell_lightning_lightningbolt01")
			self:PlaySound(164275, "info")
		end
	end
end

function mod:ParchedGasp(args)
	self:Message(args.spellId, "Important")
	self:PlaySound(args.spellId, "alarm")
	self:CDBar(args.spellId, 11) -- 10-13s
end

function mod:UncheckedGrowthSpawned()
	self:Message(164294, "Urgent", nil, CL.add_spawned)
end
