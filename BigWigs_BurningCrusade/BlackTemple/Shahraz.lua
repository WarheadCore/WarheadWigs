
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Mother Shahraz", 564, 1588)
if not mod then return end
mod:RegisterEnableMob(22947)
mod.engageId = 607
--mod.respawnTime = 0 -- Resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local playerList = mod:NewTargetList()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{41001, "SAY", "PROXIMITY"}, -- Fatal Attraction
		40883, -- Prismatic Aura: Nature
		40891, -- Prismatic Aura: Arcane
		40880, -- Prismatic Aura: Shadow
		40897, -- Prismatic Aura: Holy
		40882, -- Prismatic Aura: Fire
		40896, -- Prismatic Aura: Frost
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "FatalAttraction", 41001)
	self:Log("SPELL_AURA_REMOVED", "FatalAttractionRemoved", 41001)

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")
end

function mod:OnEngage()
	wipe(playerList)
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FatalAttraction(args)
	playerList[#playerList+1] = args.destName

	if self:Me(args.destGUID) then
		self:Say(args.spellId)
		self:OpenProximity(args.spellId, 15)
	end

	if #playerList == 1 then
		self:ScheduleTimer("TargetMessage", 0.3, args.spellId, playerList, "Urgent", "Alert")
	end
end

function mod:FatalAttractionRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(args.spellId)
	end
end

do
	local spells = {
		[40883] = true, -- Prismatic Aura: Nature
		[40891] = true, -- Prismatic Aura: Arcane
		[40880] = true, -- Prismatic Aura: Shadow
		[40897] = true, -- Prismatic Aura: Holy
		[40882] = true, -- Prismatic Aura: Fire
		[40896] = true, -- Prismatic Aura: Frost
	}
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, _, spellId)
		if spells[spellId] then
			self:Message(spellId, "Attention", "Info") -- SetOption:40883,40891,40880,40897,40882,40896:::
			self:Bar(spellId, 15)
		end
	end
end
