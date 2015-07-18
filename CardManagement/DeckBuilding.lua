local addonName, GwentAddon = ...

GwentAddon.DeckBuilding = {}

local DECK_NORTH = "Northern Realms"
local DECK_NEUTRAL = "Neutral"

-- Create a test deck to play with
-- Uses all north and neutral cards

local Deck = {}
Deck.__index = Deck
setmetatable(Deck, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


function Deck.new(leaderId)
	local self = setmetatable({}, Deck)
	
	self.leader = self:SetLeaderById(leaderId)
	self.baseDeck = {}
	
	print("deck created")
	--self.cardback = TEXTURE_CUSTOM_PATH .. texture
	
	return self
end

function Deck:AddCardById(id)
	--print("Adding id " .. id)
	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.Id == id) then
			table.insert(self.baseDeck, v)
			return
		end
	end
end

function Deck:SetLeaderById(id)
	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.Id == id) then
			return v
		end
	end
end

function Deck:PrintDeck()
	
	print("leader: " .. (self.leader ~= nil and self.leader.name or "nil"))
	print("#: " .. (#self.baseDeck))
	local text = "{ "
	
	for k, v in ipairs(self.baseDeck) do
		text = text..v.Id .. " "
	end
	
	text = text .. "}"
	print(text)
end

function Deck:Shuffle()
	
	local array = self.baseDeck
    local n = #array
    local j
    for i=n-1, 1, -1 do
        j = math.random(i)
        array[j],array[i] = array[i],array[j]
    end
    self.baseDeck = array
end

function Deck:DrawCard()
	local id = self.baseDeck[1].Id
	
	local card = GwentAddon.Card(id, GwentAddon.cards)
	
	table.remove(self.baseDeck, 1)
	
	return card
end

function GwentAddon:CreateTestDeck()
	local pDeck = Deck(1)
	local factions = GwentAddon.cards.factions

	
	
	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.faction == factions.north or v.faction == factions.neutral) and not v.cardType.leader then
			pDeck:AddCardById(v.Id)
			--table.insert(deck, v)
		end
	end

	pDeck:Shuffle()
	pDeck:PrintDeck()
	
	return pDeck
	
end





