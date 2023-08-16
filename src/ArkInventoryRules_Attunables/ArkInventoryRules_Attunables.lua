local rule = ArkInventoryRules:NewModule("ArkInventoryRules_Attunables")
local debug = false

local function strSplit(inputStr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	for str in string.gmatch(inputStr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end

	return t
end
-- ItemLink = GetContainerItemLink(bagID, slotID)
local GetContainerItemLink = GetContainerItemLink or (C_Container and C_Container.GetContainerItemLink)

-- icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(bagID, slot)
local GetContainerItemInfo = GetContainerItemInfo or (C_Container and C_Container.GetContainerItemInfo)

local function getInternalId()
	local internalId = ArkInventory.ObjectIDInternal(ArkInventoryRules.Object.h)
	return internalId
end

local function getItemId()
	local internalId = getInternalId()
	local itemId = select(2, unpack(strSplit(internalId, ":")))
	return tonumber(itemId)
end

local function getBagId()
	return ArkInventory.InternalIdToBlizzardBagId(ArkInventoryRules.Object.loc_id, ArkInventoryRules.Object.bag_id)
end

local function printDebug(bagId, value)
	if debug then
		if value then
			local link = GetContainerItemLink(bagId, ArkInventoryRules.Object.slot_id)
			if link then
				local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID =
				GetContainerItemInfo(bagId, ArkInventoryRules.Object.slot_id);
				local name = GetItemInfo(link)
				print("|cff0080ffARK: |r" .. link .. " |cffffff00isAttunable: |r" .. "|cff00ff00" ..
				tostring(value) .. "|r")
			end
		end
	end
end

local function isItemValid()
	if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.bag_id == nil or ArkInventoryRules.Object.slot_id == nil or ArkInventoryRules.Object.class ~= "item" then
		return false
	end

	return SynastriaCoreLib.IsItemValid(getItemId())
end

function rule:OnEnable()
	local registered
	registered = ArkInventoryRules.Register(self, "ATTUNABLE", rule.attunable) and
	ArkInventoryRules.Register(self, "ATTUNED", rule.attuned) and
	ArkInventoryRules.Register(self, "ATTUNEPROGRESS", rule.attuneProgress)
end

function rule.attunable(...)
	local fn = "ATTUNABLE"

	if not isItemValid() then
		return false
	end

	local blizzard_id = getItemId()
	local isItemAttunable = SynastriaCoreLib.IsAttunable(blizzard_id)

	--printDebug(getBagId(), isItemAttunable)

	return isItemAttunable
end

function rule.attuned(...)
	local fn = "ATTUNED"

	if not isItemValid() then
		return false
	end

	local blizzard_id = getItemId()
	local isItemAttuned = SynastriaCoreLib.IsAttuned(blizzard_id)

	--printDebug(getBagId(), isItemAttuned)

	return isItemAttuned
end

function rule.attuneProgress(...)
	local fn = "ATTUNEPROGRESS"

	if not isItemValid() then
		return false
	end

	local blizzard_id = getItemId()
	local itemHasAttuneProgress = SynastriaCoreLib.HasAttuneProgress(blizzard_id)

	--printDebug(getBagId(), itemHasAttuneProgress)

	return itemHasAttuneProgress
end
