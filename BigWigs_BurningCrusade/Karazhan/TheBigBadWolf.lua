--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("The Big Bad Wolf", 532, 1556)
if not mod then return end
mod:RegisterEnableMob(17521, 17603) --The Big Bad Wolf, Grandmother

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.riding_bar = "%s Running"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{30753, "ICON"}
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Riding", 30753)

	self:Death("Win", 17521)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Riding(args)
	self:TargetMessage(args.spellId, args.destName, "Attention", "Long")
	self:PrimaryIcon(args.spellId, args.destName)
	self:Bar(args.spellId, 20, L["riding_bar"]:format(args.destName))
end

