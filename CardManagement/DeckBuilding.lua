local addonName, GwentAddon = ...

GwentAddon.DeckBuilding = {}

local DECK_NORTH = "Northern Realms"
local DECK_NEUTRAL = "Neutral"

-- Create a test deck to play with
-- Uses all north and neutral cards
function GwentAddon:CreateTestDeck()

	local factions = GwentAddon.cards.factions
	local deck = {}

	for k, v in ipairs(GwentAddon.cards.list) do
		if (v.faction == factions.north or v.faction == factions.neutral) and not v.cardType.leader then
			table.insert(deck, v)
		end
	end
	
	return deck
	
end





