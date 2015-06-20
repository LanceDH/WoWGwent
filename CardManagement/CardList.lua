local addonName, GwentAddon = ...

GwentAddon.CardList = {}

local DECK_NORTH = "Northern Realms"

local ABILITY_Spy = "Spy"
local ABILITY_Bond =  "Tight Bond"

function GwentAddon:CreateCardsList()

	GwentAddon.CardList = {}

	table.insert(GwentAddon.CardList, {
				name = "Thaler"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = false, ranged = false, siege = true, hero = false}
				,ability = ABILITY_Spy
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Redanian Foot Soldier"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false}
				,ability = nil
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Poor Fucking Infantry"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = true, ranged = false, siege = false, hero = false}
				,ability = ABILITY_Bond
			})
		

	for k, v in ipairs(GwentAddon.CardList) do
		v.Id = k
		print(v.name .. " got Id " .. v.Id)

	end

	print("Card List Created")

	
end





