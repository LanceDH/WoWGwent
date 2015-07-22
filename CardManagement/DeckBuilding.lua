local addonName, GwentAddon = ...

GwentAddon.DeckBuilding = {}

local DECK_NORTH = "Northern Realms"
local DECK_NEUTRAL = "Neutral"

-- Create a test deck to play with
-- Uses all north and neutral cards

GwentAddon.DeckB = {}
GwentAddon.DeckB.__index = GwentAddon.DeckB
setmetatable(GwentAddon.DeckB, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


function GwentAddon.DeckB.new(leaderId, basedeck, backTex)
	local self = setmetatable({}, GwentAddon.DeckB)
	self.leader = {}
	self.leader.used = false
	self.leader.data = self:SetLeaderById(leaderId)
	self.cards = {}
	
	if basedeck ~= nil then
		for k, v in ipairs(basedeck) do
			table.insert(self.cards, v)
		end
	end	
	--self.cardback = TEXTURE_CUSTOM_PATH .. texture
	
	return self
end

function GwentAddon.DeckB:AddCardById(id)
	--print("Adding id " .. id)
	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.Id == id) then
			table.insert(self.cards, v)
			return
		end
	end
end

function GwentAddon.DeckB:SetLeaderById(id)
	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.Id == id) then
			return v
		end
	end
end

function GwentAddon.DeckB:PrintDeck()
	
	print("leader: " .. (self.leader ~= nil and self.leader.name or "nil"))
	print("#: " .. (#self.cards))
	local text = "{ "
	
	for k, v in ipairs(self.cards) do
		text = text..v.Id .. " "
	end
	
	text = text .. "}"
	print(text)
end

function GwentAddon.DeckB:Shuffle()
	
	local array = self.cards
    local n = #array
    local j
    for i=n-1, 1, -1 do
        j = math.random(i)
        array[j],array[i] = array[i],array[j]
    end
    self.cards = array
end

function GwentAddon.DeckB:DrawCard()
	local id = self.cards[1].Id
	
	local card = GwentAddon.Card(id, GwentAddon.cards)
	
	table.remove(self.cards, 1)
	
	return card
end

function GwentAddon:CreateTestDeck(faction)
	local factions = GwentAddon.cards.factions
	local id = 1
	if faction == factions.scoiatael then
		id = 54
	elseif faction == factions.nilf then
		id = 87
	elseif faction == factions.monster then
		id = 126
	end 
	local pDeck = GwentAddon.DeckB(id)
	
	
	
	
	

	-- "Northern Realms"
	-- "Neutral"
	-- "Scoia’tael"
	
	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.faction == faction or v.faction == "Neutral") and not v.cardType.leader then
			pDeck:AddCardById(v.Id)
			--table.insert(deck, v)
		end
	end

	pDeck:Shuffle()
	pDeck:PrintDeck()
	
	return pDeck
	
end





