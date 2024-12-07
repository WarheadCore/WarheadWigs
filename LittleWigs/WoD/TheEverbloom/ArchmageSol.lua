
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Archmage Sol", 1279, 1208)
if not mod then return end
mod:RegisterEnableMob(82682)
mod.engageId = 1751
mod.respawnTime = 15

-------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return
	{
		427899, -- Cinderbolt Storm
		428082, -- Glacial Fusion
		428139, -- Spatial Compression
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "FireAffinity", 166475)
	self:Log("SPELL_AURA_APPLIED", "FrostAffinity", 166476)
	self:Log("SPELL_AURA_APPLIED", "ArcaneAffinity", 166477)
end

function mod:OnEngage()
	self:CDBar(427899, 3.3) -- Cinderbolt Storm
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FireAffinity()
	self:StopBar(428082) -- Glacial Fusion
	self:CDBar(428082, 21) -- Glacial Fusion
end

function mod:FrostAffinity()
	self:StopBar(428139) -- Spatial Compression
	self:CDBar(428139, 21) -- Spatial Compression
end

function mod:ArcaneAffinity()
	self:StopBar(427899) -- Cinderbolt Storm
	self:CDBar(427899, 21) -- Cinderbolt Storm
end
