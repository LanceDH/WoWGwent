local addonName, GwentAddon = ...

GwentAddon.CardList = {}

local DECK_NORTH = "Northern Realms"

local ABILITY_Spy = "Spy"
local ABILITY_Bond = "Tight Bond"
local ABILITY_Hero = "Immune to special cards"

function GwentAddon:CreateCardsList()

	GwentAddon.CardList = {}

	table.insert(GwentAddon.CardList, {
				name = "Foltest, King of Temeria"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = 0, ranged = 0, siege = 0, hero = 0, leader = 1}
				,ability = "NYI"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Foltest, Lord Commander Of The North"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = 0, ranged = 0, siege = 0, hero = 0, leader = 1}
				,ability = "NYI"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Foltest The Steel-forged"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = 0, ranged = 0, siege = 0, hero = 0, leader = 1}
				,ability = "NYI"
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Foltest The Siegemaster"
				,deck = DECK_NORTH
				,strength = 0
				,cardType = {melee = 0, ranged = 0, siege = 0, hero = 0, leader = 1}
				,ability = "NYI"
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Philippa Eilhart"
				,deck = DECK_NORTH
				,strength = 10
				,cardType = {melee = 0, ranged = 1, siege = 0, hero = 1, leader = 0}
				,ability = ABILITY_Hero
			})
	
	table.insert(GwentAddon.CardList, {
				name = "Thaler"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = 0, ranged = 0, siege = 1, hero = 0, leader = 0}
				,ability = ABILITY_Spy
			})
			
	table.insert(GwentAddon.CardList, {
name = "Redanian Foot Soldier"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = 1, ranged = 0, siege = 0, hero = 0, leader = 0}
				,ability = nil
			})
			
	table.insert(GwentAddon.CardList, {
				name = "Poor Fucking Infantry"
				,deck = DECK_NORTH
				,strength = 1
				,cardType = {melee = 1, ranged = 0, siege = 0, hero = 0, leader = 0}
				,ability = ABILITY_Bond
			})
		

	for k, v in ipairs(GwentAddon.CardList) do
		v.Id = k
	end

	
end





