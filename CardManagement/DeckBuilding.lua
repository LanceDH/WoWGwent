local addonName, GwentAddon = ...

GwentAddon.DeckBuilding = {}

local DECK_NORTH = "Northern Realms"
local DECK_NEUTRAL = "Neutral"

function GwentAddon:CreateTestDeck()

	local deck = {}

	for k, v in ipairs(GwentAddon.CardList) do
		if (v.faction == DECK_NORTH or v.faction == DECK_NEUTRAL) and not v.cardType.leader then
			table.insert(deck, v)
		end
	end
	
	return deck
	
end





