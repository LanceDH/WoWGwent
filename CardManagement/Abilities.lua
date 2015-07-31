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

function Ability.new(name, isLeader, texture, abilityFunction, onPlay)
	local self = setmetatable({}, Abilities)
	
	self.name = name
	self.isLeader = false
	
	self.isOnPlay = (onPlay == nil and false or onPlay) -- true = ability only triggers when played
	self.isTriggered = false -- wether on play has been triggered
	self.texture = TEXTURE_CUSTOM_PATH .. texture
	self.funct = function(card, list, deck, pos, extra) abilityFunction(card, list, deck, pos, extra) end
	
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
	
	card.data.calcStrength = card.data.calcStrength + (card.data.weatherStrength * count);
	card:UpdateCardStrength();
end

-- Morale Boost
--
-- Adds +1 to all units in the row (excluding itself)
local function AbilityMoraleBoost(card, list)
	for k, lCard in pairs(list) do
		-- exlude self and hero characters
		if lCard.data.Id ~= card.data.Id and not lCard.data.cardType.hero then
			lCard.data.calcStrength = lCard.data.weatherStrength + 1
			lCard:UpdateCardStrength()
		end
	end
end

local function GetStrongestInList(str, list)
	for k, v in ipairs(list) do
		if not v.data.cardType.hero and v.data.calcStrength > str then 
			str = v.data.calcStrength
		end
	end
	
	return str
	
end

local function DestroyCardInListByStrength(str, list)
	local card = nil
	for i=#list, 1, -1 do
		card = list[i]
		if not card.data.cardType.hero and card.data.calcStrength == tonumber(str) then
			table.insert(GwentAddon.cardPool, card.frame)
			card.frame:Hide()

			table.remove(list, i)
		end
	end
end

local function DiscardCardsInListByStrength(str, list)
	local card = nil
	for i=#list, 1, -1 do
		card = list[i]
		if not card.data.cardType.hero and card.data.calcStrength == tonumber(str) then
			GwentAddon.cards:AddCardToNewList(card, "graveyard")
			GwentAddon:ChangeGraveyardDisplay(card.data.texture)
			table.remove(list, i)
		end
	end
end


function GwentAddon:ScorchCards(str)
	DiscardCardsInListByStrength(str, GwentAddon:GetListByName("playerMelee"))
	DiscardCardsInListByStrength(str, GwentAddon:GetListByName("playerRanged"))
	DiscardCardsInListByStrength(str, GwentAddon:GetListByName("playerSiege"))
	
	DestroyCardInListByStrength(str, GwentAddon:GetListByName("enemyMelee"))
	DestroyCardInListByStrength(str, GwentAddon:GetListByName("enemyRanged"))
	DestroyCardInListByStrength(str, GwentAddon:GetListByName("enemySiege"))
	
	GwentAddon:PlaceAllCards()
end

-- Spy
--
-- place on opponent field and draw 2 cards
local function AbilitySpy(card, list, deck, pos, area)
	-- draw 2 cards
	table.insert(GwentAddon.lists.playerHand, deck:DrawCard())
	table.insert(GwentAddon.lists.playerHand, deck:DrawCard())
	
	SendAddonMessage(addonName, GwentAddon.messages.ability.. "Spy#"..card.data.Id.."#"..area.."#"..pos.."#", "whisper" , GwentAddon.challengerName)
	
end

local function AbilitySpyCreate(card, list, deck, message)

	local id, area, pos = string.match(message, "#(%d+)#(%a+)#(%d+)#")

	local cSpy = GwentAddon.Card(id, GwentAddon.cards)

	table.insert(GwentAddon:GetListByName("player"..area), pos, cSpy)
	
end

-- Scorch
--
-- Kill the strongest card(s) on the battlefield
local function AbilityScorch(card, list)
	local topStr = 0
	topStr = GetStrongestInList(topStr, GwentAddon:GetListByName("playerMelee"))
	topStr = GetStrongestInList(topStr, GwentAddon:GetListByName("playerRanged"))
	topStr = GetStrongestInList(topStr, GwentAddon:GetListByName("playerSiege"))
	topStr = GetStrongestInList(topStr, GwentAddon:GetListByName("enemyMelee"))
	topStr = GetStrongestInList(topStr, GwentAddon:GetListByName("enemyRanged"))
	topStr = GetStrongestInList(topStr, GwentAddon:GetListByName("enemySiege"))
	
	-- discard card from list
	GwentAddon:ScorchCards(topStr)
	
	if card ~= nil then
		SendAddonMessage(addonName, GwentAddon.messages.ability.. "Scorch", "whisper" , GwentAddon.challengerName)
	end
end


-- Muster
--
-- Find any cards with the same name in your deck and play them instantly
local function AbilityMuster(card, list, deck, pos, area)
	local prefix = string.match(card.data.name, "(%a+):")
	
	local c = nil
	for i = #deck.cards, 1, -1 do
		c = deck.cards[i]
		
		if c.name == card.data.name or (prefix and string.find(c.name, prefix)) then
			pos = pos + 1
			table.insert(list, pos, GwentAddon.Card.new(c.Id, GwentAddon.cards))
			SendAddonMessage(addonName, GwentAddon.messages.placeCard..string.format(GwentAddon.messages.placeInArea, area, c.Id, pos), "whisper" , GwentAddon.challengerName)
			table.remove(deck.cards, i)
		end
	end
	
	local hand = GwentAddon:GetListByName("playerHand")
	
	for i = #hand, 1, -1 do
		c = hand[i]
		
		if c.data.name == card.data.name or (prefix and string.find(c.data.name, prefix)) then
			pos = pos + 1
			table.insert(list, pos, c)
			SendAddonMessage(addonName, GwentAddon.messages.placeCard..string.format(GwentAddon.messages.placeInArea, area, c.data.Id, pos), "whisper" , GwentAddon.challengerName)
			table.remove(hand, i)
		end
	end
	
	
end

-- Weather Biting Frost
--
-- Set strength of all melee to 1
local function AbilityBitingFrost(card, list, deck, pos, area)
	GwentAddon:ChangeWeatherOverlay("melee", true)
	
	if card ~= nil then
		SendAddonMessage(addonName, GwentAddon.messages.ability.."BitingFrost", "whisper" , GwentAddon.challengerName)
	end
end

-- Weather Impenetrable Fog
--
-- Set strength of all ranged to 1
local function AbilityImpenetrableFog(card, list, deck, pos, area)
	GwentAddon:ChangeWeatherOverlay("ranged", true)
	
	if card ~= nil then
		SendAddonMessage(addonName, GwentAddon.messages.ability.."ImpenetrableFog", "whisper" , GwentAddon.challengerName)
	end
end

-- Weather Torrential Rain
--
-- Set strength of all ranged to 1
local function AbilityTorrentialRain(card, list, deck, pos, area)
	GwentAddon:ChangeWeatherOverlay("siege", true)
	
	if card ~= nil then
		SendAddonMessage(addonName, GwentAddon.messages.ability.."TorrentialRain", "whisper" , GwentAddon.challengerName)
	end
end

-- Clear Weather
--
-- Remove all weather cards in play
local function AbilityClearWeather(card, list, deck, pos, area)
	GwentAddon:ChangeWeatherOverlay("melee", false)
	GwentAddon:ChangeWeatherOverlay("ranged", false)
	GwentAddon:ChangeWeatherOverlay("siege", false)
	
	local list = GwentAddon:GetListByName("weather")
	local card = nil
	for i = #list, 1, -1 do
		card = list[i]
		table.insert(GwentAddon.cardPool, card.frame)
		card.frame:Hide()
		table.remove(list, i)
	end
	
	if card ~= nil then
		SendAddonMessage(addonName, GwentAddon.messages.ability.."ClearWeather", "whisper" , GwentAddon.challengerName)
	end
end

local function AbilityCommandersHorn(card, name, deck, message)
	if card then
		-- player side
		-- function only for special cards
		if not card.data.cardType.special then return end 
		
		local area = GwentAddon:GetAreaByName(name)
		
		area.commander.card.frame:Show()
	
		SendAddonMessage(addonName, GwentAddon.messages.ability.."CommandersHorn#"..name, "whisper" , GwentAddon.challengerName)
	else 
		-- enemy side
		local name = string.match("Ability: CommandersHorn#playerMelee", "Ability: CommandersHorn#(%a+)")
		name = string.gsub(name, "player", "enemy")
		local area = GwentAddon:GetAreaByName(name)
		
		area.commander.card.frame:Show()
	
	end
end

-- Create a list of abilities
function GwentAddon:CreateAbilitieList()

	GwentAddon.Abilities = {}

	table.insert(GwentAddon.Abilities, Ability("Spy", false, "AbilitySpy", function(card, list, deck, pos, message) 
																				if card ~= nil then 
																					AbilitySpy(card, list, deck, pos, message) 
																				else 
																					AbilitySpyCreate(card, list, deck, pos, message) 
																				end end, true));
	table.insert(GwentAddon.Abilities, Ability("TightBond", false, "AbilityBond", function(card, list, deck, pos) AbilityTightBond(card, list, pos) end));
	table.insert(GwentAddon.Abilities, Ability("MoraleBoost", false, "AbilityBoost", function(card, list, deck) AbilityMoraleBoost(card, list) end));
	table.insert(GwentAddon.Abilities, Ability("Medic", false, "AbilityMedic", function(card, list, deck) end)); -- NYI
	table.insert(GwentAddon.Abilities, Ability("Muster", false, "AbilityMuster", function(card, list, deck, pos, area) AbilityMuster(card, list, deck, pos, area) end, true));
	table.insert(GwentAddon.Abilities, Ability("Agile", false, "AbilityAgile", function(card, list, deck)  end));
	table.insert(GwentAddon.Abilities, Ability("CommandersHorn", false, "AbilityCommander", function(card, list, deck, pos) AbilityCommandersHorn(card, list, deck, pos) end));
	table.insert(GwentAddon.Abilities, Ability("Scorch", false, "AbilityScorch", function(card, list, deck) AbilityScorch(card, list) end, true));
	table.insert(GwentAddon.Abilities, Ability("BitingFrost", false, "AbilityBitingFrost", function(card, list, deck) AbilityBitingFrost(card, list, deck) end, true));
	table.insert(GwentAddon.Abilities, Ability("ImpenetrableFog", false, "AbilityImpenetrableFog", function(card, list, deck) AbilityImpenetrableFog(card, list, deck) end, true));
	table.insert(GwentAddon.Abilities, Ability("TorrentialRain", false, "AbilityTorrentialRain", function(card, list, deck) AbilityTorrentialRain(card, list, deck) end, true));
	table.insert(GwentAddon.Abilities, Ability("ClearWeather", false, "AbilityClearWeather", function(card, list, deck) AbilityClearWeather(card, list, deck) end, true));
		
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





