local addonName, GwentAddon = ...

GwentAddon.Abilities = {}

--[[
Spy 
- Tight Bond 
- Morale Boost 
- Medic 
- Muster 
- Agile 
- Scorch
]]--

local COORDS_ICON_MELEE = {["x"]=64*7, ["y"]=64*7}
local TEXTURE_ICONS = {["path"]="Interface\\GUILDFRAME\\GUILDEMBLEMSLG_01", ["width"]=1024, ["height"]=1024}
local NUM_SIZE_ICON = 64
local TEXTURE_CARD_BG = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"
local TEXTURE_SPY = {["path"]="Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-14", ["width"]=128, ["height"]=128}
local TEXTURE_CUSTOM_PATH = "Interface\\AddOns\\Gwent\\CardTextures\\"

local Ability = {}
Ability.__index = Ability
setmetatable(Ability, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Ability.new(name, isLeader, texture, abilityFunction)
	local self = setmetatable({}, Abilities)
	
	self.name = name
	self.isLeader = false
	self.texture = TEXTURE_CUSTOM_PATH .. texture
	self.funct = function(card, list, pos) abilityFunction(card, list, pos) end
	
	return self
end

-- Count successive same name cards on the left
-- Used for tight bond
local function CountSameNameOnLeft(card, list, pos) 
	if pos == 1 then return 0 end -- is left most card
	local count = 0
	
	if ( list[pos-1].data.name == card.data.name ) then
		count = count + 1
		count = count + CountSameNameOnLeft(card, list, pos-1) 
	end
	return count
end

-- Count successive same name cards on the right
-- Used for tight bond
local function CountSameNameOnRight(card, list, pos) 
	if pos == #list then return 0 end -- is right most card
	local count = 0
	
	if ( list[pos+1].data.name == card.data.name ) then
		count = count + 1
		count = count + CountSameNameOnRight(card, list, pos+1) 
	end
	return count
end

-- Tight Bond
--
-- Place next to card card with the same name to double the strength of both cards.
local function AbilityTightBond(card, list, pos)
	local left = CountSameNameOnLeft(card, list, pos);
	local right = CountSameNameOnRight(card, list, pos);
	local count = left + right;
	
	card.data.calcStrength = card.data.calcStrength + (card.data.strength * count);
	card:UpdateCardStrength();
end

-- Morale Boost
--
-- Adds +1 to all units in the row (excluding itself)
local function AbilityMoraleBoost(card, list)
	for k, lCard in pairs(list) do
		-- exlude self and hero characters
		if lCard.data.Id ~= card.data.Id and not lCard.data.cardType.hero then
			lCard.data.calcStrength = lCard.data.calcStrength + 1
			lCard:UpdateCardStrength()
		end
	end
end

-- Create a list of abilities
function GwentAddon:CreateAbilitieList()

	GwentAddon.Abilities = {}

	table.insert(GwentAddon.Abilities, Ability("Spy", false, "AbilitySpy", function(card, list, pos)  end)); -- NYI
	table.insert(GwentAddon.Abilities, Ability("Tight Bond", false, "AbilityBond", function(card, list, pos) AbilityTightBond(card, list, pos) end));
	table.insert(GwentAddon.Abilities, Ability("Morale Boost", false, "AbilityBoost", function(card, list, pos) AbilityMoraleBoost(card, list) end));
	table.insert(GwentAddon.Abilities, Ability("Medic", false, "AbilityMedic", function(card, list, pos) end)); -- NYI
	table.insert(GwentAddon.Abilities, Ability("Muster", false, "AbilityMuster", function(card, list, pos)  end)); -- NYI
	table.insert(GwentAddon.Abilities, Ability("Agile", false, "AbilityAgile", function(card, list, pos)  end)); -- NYI
	table.insert(GwentAddon.Abilities, Ability("Scorch", false, "AbilityScorch", function(card, list, pos)  end)); -- NYI
	
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Spy"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilitySpy"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
			
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Tight Bond"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityBond"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
			
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Morale Boost"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityBoost"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
			
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Medic"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityMedic"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
			
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Muster"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityMuster"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
			
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Agile"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityAgile"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
	
	-- table.insert(GwentAddon.Abilities, {
				-- name = "Scorch"
				-- ,isLeader = false
				-- ,texture = "Interface\\AddOns\\Gwent\\CardTextures\\AbilityScorch"
				-- ,coords = {left = 0
							-- ,right = 1
							-- ,top = 0
							-- ,bottom = 1}
			-- })
			
	for k, v in ipairs(GwentAddon.Abilities) do
		v.Id = k
	end

	
end

-- Get a specific ability by name
function GwentAddon:GetAbilitydataByName(name)
	
	for k, v in pairs(GwentAddon.Abilities) do
		--GwentAddon:DEBUGMessageSent(name .. " - ".. v.name)
		if v.name == name then
			return v
		end
	end
	return nil
end

-- Set the ability icon of a card
function GwentAddon:SetAblityIcon(card, data)

	local ability = data.ability --GwentAddon:GetAbilitydataByName(card.data.ability)
		
	if ability == nil then return end
	
	local vc = 0
	if data.cardType.hero then
		vc = 1
	end
	
	card.iconAbility:SetVertexColor(vc, vc, vc)
	card.abilityBG:Show()
	card.iconAbility:SetTexture(ability.texture)
	--card.iconAbility:SetTexCoord(ability.coords.left, ability.coords.right, ability.coords.top, ability.coords.bottom)

end





