
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sadana Bloodfury", 1176, 1139)
if not mod then return end
mod:RegisterEnableMob(75509)
mod.engageId = 1677
mod.respawnTime = 15

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.custom_on_markadd = "Mark the Dark Communion Add"
	L.custom_on_markadd_desc = "Mark the add spawned by Dark Communion with {rt8}, requires promoted or leader."
	L.custom_on_markadd_icon = 8
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		164974, -- Dark Eclipse
		153240, -- Daggerfall
		153153, -- Dark Communion
		"custom_on_markadd", -- Add marker option
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "DarkEclipse", 164974)
	self:Log("SPELL_CAST_SUCCESS", "Daggerfall", 153240)
	self:Log("SPELL_CAST_SUCCESS", "DarkCommunion", 153153)
end

function mod:OnEngage()
	self:CDBar(164974, 48) -- Dark Eclipse
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DarkEclipse(args)
	self:Bar(args.spellId, 6, CL.cast:format(args.spellName))
	self:CDBar(164974, 48)
	self:Message(args.spellId, "Urgent", "Warning", CL.casting:format(args.spellName))
end

do
	local function printTarget(self, player, guid)
		if self:Me(guid) then
			self:Flash(153240)
			self:Say(153240)
		end

		self:TargetMessage(153240, player, "Attention", "Alert")
	end

	function mod:Daggerfall(args)
		self:GetBossTarget(printTarget, 0.2, args.sourceGUID)
	end
end

function mod:FindAdd(_, unit, guid)
	if self:MobId(guid) == 75966 then -- Defiled Spirit
		SetRaidTarget(unit, 8)
		self:UnregisterTargetEvents()
	end
end

function mod:DarkCommunion(args)
	self:Message(args.spellId, "Positive", "Info", CL.add_spawned)
	self:Bar(args.spellId, 60, CL.next_add)

	if self:GetOption("custom_on_markadd") then
		self:RegisterTargetEvents("FindAdd")
	end
end
